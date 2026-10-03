%%%-------------------------------------------------------------------
%%% @doc Session registry.
%%%
%%% Tracks which process currently holds a live session for each
%%% (user, device) pair. A user may be logged in on several devices at
%%% once, up to ?MAX_DEVICES_PER_USER.
%%%
%%% Writes (register/unregister) go through the gen_server so that there
%%% is exactly one writer. Reads (lookup/devices/count) go straight to
%%% the ETS table and never touch the server process.
%%%
%%% Every session process is monitored; when it dies its row is removed
%%% automatically, so the table never holds dead pids.
%%%
%%% This module is READ-ONLY for the exercise.
%%% @end
%%%-------------------------------------------------------------------
-module(session_registry).
-behaviour(gen_server).

%%% API
-export([start_link/0, stop/0,
         register/2, unregister/2,
         lookup/1, devices/1, count/0,
         broadcast/2]).

%%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-include_lib("kernel/include/logger.hrl").

-define(TABLE, ?MODULE).
-define(MAX_DEVICES_PER_USER, 4).

-type user_id()   :: binary().
-type device_id() :: binary().

%% One row in the ETS table. The table key is the `key' field, so the
%% table is created with {keypos, #session.key}.
-record(session, {
    key   :: {user_id(), device_id()},
    pid   :: pid(),
    mref  :: reference(),       % monitor on `pid'
    since :: integer()          % erlang:system_time(millisecond)
}).

%% The server's own state. The reverse index lets a 'DOWN' message (which
%% only carries the monitor reference) find the row to delete.
-record(state, {
    table    :: ets:tid(),
    monitors = #{} :: #{reference() => {user_id(), device_id()}}
}).

-type state() :: #state{}.

%%%===================================================================
%%% API
%%%===================================================================

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec stop() -> ok.
stop() ->
    gen_server:stop(?MODULE).

%% Register the CALLING process as the session for {UserId, DeviceId}.
%% Registering the same device again replaces the previous session.
-spec register(user_id(), device_id()) -> ok | {error, too_many_devices}.
register(UserId, DeviceId) when is_binary(UserId), is_binary(DeviceId) ->
    gen_server:call(?MODULE, {register, UserId, DeviceId, self()}).

-spec unregister(user_id(), device_id()) -> ok.
unregister(UserId, DeviceId) ->
    gen_server:cast(?MODULE, {unregister, UserId, DeviceId}).

%% All live sessions of a user as {DeviceId, Pid}, sorted by device.
%% Reads the table directly: no message to the server.
-spec lookup(user_id()) -> [{device_id(), pid()}].
lookup(UserId) ->
    MatchSpec = [{#session{key = {UserId, '$1'}, pid = '$2', _ = '_'},
                  [],
                  [{{'$1', '$2'}}]}],
    lists:sort(ets:select(?TABLE, MatchSpec)).

-spec devices(user_id()) -> [device_id()].
devices(UserId) ->
    [DeviceId || {DeviceId, _Pid} <- lookup(UserId)].

-spec count() -> non_neg_integer().
count() ->
    ets:info(?TABLE, size).

%% Send Msg to every session process of a user. Returns how many were sent.
-spec broadcast(user_id(), term()) -> non_neg_integer().
broadcast(UserId, Msg) ->
    Sessions = lookup(UserId),
    lists:foreach(fun({_DeviceId, Pid}) -> Pid ! {session_msg, Msg} end,
                  Sessions),
    length(Sessions).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec init([]) -> {ok, state()}.
init([]) ->
    Table = ets:new(?TABLE, [set, named_table, protected,
                             {keypos, #session.key},
                             {read_concurrency, true}]),
    {ok, #state{table = Table}}.

-spec handle_call(term(), gen_server:from(), state()) ->
          {reply, term(), state()}.
handle_call({register, UserId, DeviceId, Pid}, _From, State0) ->
    Key = {UserId, DeviceId},
    %% Drop any previous session for this exact device first, so that a
    %% reconnecting device never counts against its own limit.
    State1 = remove_session(Key, State0),
    case length(lookup(UserId)) >= ?MAX_DEVICES_PER_USER of
        true ->
            {reply, {error, too_many_devices}, State1};
        false ->
            MRef = erlang:monitor(process, Pid),
            Session = #session{key = Key,
                               pid = Pid,
                               mref = MRef,
                               since = erlang:system_time(millisecond)},
            true = ets:insert(?TABLE, Session),
            Monitors = maps:put(MRef, Key, State1#state.monitors),
            {reply, ok, State1#state{monitors = Monitors}}
    end;
handle_call(Request, From, State) ->
    ?LOG_WARNING("~p: unexpected call ~p from ~p", [?MODULE, Request, From]),
    {reply, {error, {unknown_call, Request}}, State}.

-spec handle_cast(term(), state()) -> {noreply, state()}.
handle_cast({unregister, UserId, DeviceId}, State) ->
    {noreply, remove_session({UserId, DeviceId}, State)};
handle_cast(Msg, State) ->
    ?LOG_WARNING("~p: unexpected cast ~p", [?MODULE, Msg]),
    {noreply, State}.

%% A monitored session process died. 'DOWN' carries the monitor ref, the
%% reverse index turns that into the table key.
-spec handle_info(term(), state()) -> {noreply, state()}.
handle_info({'DOWN', MRef, process, _Pid, _Reason},
            #state{monitors = Monitors} = State) ->
    case maps:take(MRef, Monitors) of
        {Key, Rest} ->
            true = ets:delete(?TABLE, Key),
            {noreply, State#state{monitors = Rest}};
        error ->
            %% Already removed by unregister/2; a stale 'DOWN'. Ignore.
            {noreply, State}
    end;
handle_info(Info, State) ->
    ?LOG_WARNING("~p: unexpected info ~p", [?MODULE, Info]),
    {noreply, State}.

%% Nothing to do: the ETS table is owned by this process and disappears
%% with it, and monitors die with the monitoring process.
-spec terminate(term(), state()) -> ok.
terminate(_Reason, _State) ->
    ok.

-spec code_change(term(), state(), term()) -> {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% Remove one session (if present): drop the monitor, the row and the
%% reverse-index entry. Safe to call for a key that is not registered.
-spec remove_session({user_id(), device_id()}, state()) -> state().
remove_session(Key, #state{monitors = Monitors} = State) ->
    case ets:lookup(?TABLE, Key) of
        [#session{mref = MRef}] ->
            %% [flush] also removes a 'DOWN' that may already be queued.
            true = erlang:demonitor(MRef, [flush]),
            true = ets:delete(?TABLE, Key),
            State#state{monitors = maps:remove(MRef, Monitors)};
        [] ->
            State
    end.
