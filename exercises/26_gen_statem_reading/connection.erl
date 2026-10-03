%%%-------------------------------------------------------------------
%%% @doc A toy connection state machine built on gen_statem.
%%%
%%% States:  disconnected  <-->  connected
%%%
%%% A connected peer that stays idle for `idle_ms' is dropped back to
%%% `disconnected' by a state timeout. Any `send' resets the idle timer.
%%%
%%% This module is READ-ONLY for the exercise. Read it top to bottom,
%%% then answer the questions in connection_tests.erl.
%%% @end
%%%-------------------------------------------------------------------
-module(connection).
-behaviour(gen_statem).

%%% API
-export([start_link/1, connect/1, disconnect/1, send/2, history/1,
         state/1, stop/1]).

%%% gen_statem callbacks
-export([callback_mode/0, init/1, terminate/3, code_change/4]).

%%% State functions (one exported function per state)
-export([disconnected/3, connected/3]).

-define(DEFAULT_IDLE_MS, 60000).

-record(data, {
    peer    :: binary(),              % who we are talking to
    idle_ms :: pos_integer(),         % drop the connection after this much silence
    seq = 0 :: non_neg_integer(),     % sequence number of the last message sent
    sent = [] :: [binary()]           % every payload sent, newest first
}).

-type data() :: #data{}.

%%%===================================================================
%%% API
%%%===================================================================

-spec start_link(map()) -> {ok, pid()} | {error, term()}.
start_link(Opts) ->
    gen_statem:start_link(?MODULE, Opts, []).

-spec connect(pid()) -> ok | {error, already_connected}.
connect(Pid) ->
    gen_statem:call(Pid, connect).

-spec disconnect(pid()) -> ok | {error, already_disconnected}.
disconnect(Pid) ->
    gen_statem:call(Pid, disconnect).

-spec send(pid(), binary()) -> {ok, Seq :: pos_integer()} | {error, disconnected}.
send(Pid, Payload) when is_binary(Payload) ->
    gen_statem:call(Pid, {send, Payload}).

-spec history(pid()) -> [binary()].
history(Pid) ->
    gen_statem:call(Pid, history).

%% For gen_statem, sys:get_state/1 returns {StateName, Data}.
-spec state(pid()) -> disconnected | connected.
state(Pid) ->
    {State, _Data} = sys:get_state(Pid),
    State.

-spec stop(pid()) -> ok.
stop(Pid) ->
    gen_statem:stop(Pid).

%%%===================================================================
%%% gen_statem callbacks
%%%===================================================================

%% `state_functions' means: the current state is an atom, and events are
%% delivered to the function with that name, e.g. connected(EventType,
%% Event, Data). The other mode, `handle_event_function', funnels every
%% event through a single handle_event/4.
-spec callback_mode() -> gen_statem:callback_mode().
callback_mode() ->
    state_functions.

-spec init(map()) -> {ok, disconnected, data()}.
init(Opts) ->
    Peer = maps:get(peer, Opts, <<"unknown">>),
    IdleMs = maps:get(idle_ms, Opts, ?DEFAULT_IDLE_MS),
    {ok, disconnected, #data{peer = Peer, idle_ms = IdleMs}}.

terminate(_Reason, _State, _Data) ->
    ok.

code_change(_OldVsn, State, Data, _Extra) ->
    {ok, State, Data}.

%%%===================================================================
%%% State: disconnected
%%%===================================================================

%% Every state function receives (EventType, EventContent, Data).
%% A synchronous call arrives as EventType = {call, From}; the reply is
%% sent via the {reply, From, Reply} ACTION in the returned list.
disconnected({call, From}, connect, #data{idle_ms = IdleMs} = Data) ->
    Actions = [{reply, From, ok},
               {state_timeout, IdleMs, idle}],   % arm the idle timer
    {next_state, connected, Data, Actions};
disconnected({call, From}, {send, _Payload}, Data) ->
    {keep_state, Data, [{reply, From, {error, disconnected}}]};
disconnected({call, From}, disconnect, Data) ->
    {keep_state, Data, [{reply, From, {error, already_disconnected}}]};
disconnected(EventType, Event, Data) ->
    handle_common(EventType, Event, Data).

%%%===================================================================
%%% State: connected
%%%===================================================================

connected({call, From}, {send, Payload},
          #data{seq = Seq, sent = Sent, idle_ms = IdleMs} = Data) ->
    NewSeq = Seq + 1,
    NewData = Data#data{seq = NewSeq, sent = [Payload | Sent]},
    %% Setting state_timeout again REPLACES the running one: activity
    %% pushes the idle deadline out.
    Actions = [{reply, From, {ok, NewSeq}},
               {state_timeout, IdleMs, idle}],
    {keep_state, NewData, Actions};
connected({call, From}, disconnect, Data) ->
    %% Leaving the state cancels any pending state_timeout automatically.
    {next_state, disconnected, Data, [{reply, From, ok}]};
connected({call, From}, connect, _Data) ->
    {keep_state_and_data, [{reply, From, {error, already_connected}}]};
connected(state_timeout, idle, Data) ->
    %% The idle timer fired: nobody sent anything for idle_ms.
    {next_state, disconnected, Data};
connected(EventType, Event, Data) ->
    handle_common(EventType, Event, Data).

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% Events that mean the same thing in every state. Each state function
%% delegates here from its last clause; you will often see this done with
%% a macro like ?HANDLE_COMMON in production code.
handle_common({call, From}, history, #data{sent = Sent} = Data) ->
    {keep_state, Data, [{reply, From, lists:reverse(Sent)}]};
handle_common({call, From}, Event, Data) ->
    {keep_state, Data, [{reply, From, {error, {unknown_event, Event}}}]};
handle_common(_EventType, _Event, Data) ->
    %% info messages (plain `!'), casts we do not know, etc.: ignore.
    {keep_state, Data}.
