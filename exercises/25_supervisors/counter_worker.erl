%%%-------------------------------------------------------------------
%%% @doc A tiny counter gen_server, used as the supervised child in this
%%% exercise. READ-ONLY: you do not need to change anything here.
%%% @end
%%%-------------------------------------------------------------------
-module(counter_worker).
-behaviour(gen_server).

%%% API
-export([start_link/0, child_spec/0, incr/0, value/0, crash/0, stop/0]).

%%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%%%===================================================================
%%% API
%%%===================================================================

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

%% Modules often export their own child spec so the supervisor does not need
%% to know the details. This is the modern MAP form of a child spec.
-spec child_spec() -> supervisor:child_spec().
child_spec() ->
    #{id => ?MODULE,                    % unique within the supervisor
      start => {?MODULE, start_link, []}, % {Module, Function, Args}
      restart => permanent,             % permanent | transient | temporary
      shutdown => 5000,                 % ms to wait for terminate/2
      type => worker,                   % worker | supervisor
      modules => [?MODULE]}.            % for hot code upgrades

-spec incr() -> ok.
incr() ->
    gen_server:cast(?MODULE, incr).

-spec value() -> non_neg_integer().
value() ->
    gen_server:call(?MODULE, value).

%% Deliberately crash the server (exit reason: `boom').
-spec crash() -> ok.
crash() ->
    gen_server:cast(?MODULE, crash).

%% Stop the server with reason `normal'.
-spec stop() -> ok.
stop() ->
    gen_server:stop(?MODULE).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

init([]) ->
    {ok, 0}.

handle_call(value, _From, Count) ->
    {reply, Count, Count};
handle_call(Request, _From, Count) ->
    {reply, {error, {unknown_call, Request}}, Count}.

handle_cast(incr, Count) ->
    {noreply, Count + 1};
handle_cast(crash, Count) ->
    %% {stop, Reason, State} with a non-normal Reason: the process exits
    %% abnormally and the supervisor sees a crash.
    {stop, boom, Count};
handle_cast(_Msg, Count) ->
    {noreply, Count}.

handle_info(_Info, Count) ->
    {noreply, Count}.

terminate(_Reason, _Count) ->
    ok.

code_change(_OldVsn, Count, _Extra) ->
    {ok, Count}.
