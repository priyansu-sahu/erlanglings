%% I AM NOT DONE
-module(server_loop).

%% A key-value store as a plain process. This is the pattern that gen_server
%% generalizes, written out by hand so you can see every moving part.
%%
%% Read it top to bottom. The layout -- "API" functions that run in the
%% CALLER's process, a "loop" that runs in the SERVER's process, and a
%% "handle" function that is pure -- is the same layout every gen_server
%% module has:
%%
%%   API           -> gen_server:call / gen_server:cast wrappers
%%   call/2        -> gen_server:call internals (ref, send, receive, timeout)
%%   loop/1        -> the gen_server main loop (you never write this)
%%   handle/2      -> handle_call/3 and handle_cast/2 callbacks
%%
%% Note how State is threaded: loop(State) receives, computes NewState, and
%% calls loop(NewState). No mutation anywhere -- the "variable" is the
%% argument of the recursive call.

%% API (runs in the caller's process)
-export([start/0, stop/1, put/3, get/2, delete/2, size/1, incr/2]).
%% internal export for spawn/3
-export([init/0]).
%% exported so the tests (and you) can call the pure part directly
-export([handle_call/2, handle_cast/2]).

-define(TIMEOUT, 1000).

-spec start() -> pid().
start() ->
    spawn(?MODULE, init, []).

-spec stop(pid()) -> ok.
stop(Pid) ->
    call(Pid, stop).

%% Store Value under Key. Returns ok.
-spec put(pid(), term(), term()) -> ok.
put(Pid, Key, Value) ->
    call(Pid, {put, Key, Value}).

%% {ok, Value} or {error, not_found}.
-spec get(pid(), term()) -> {ok, term()} | {error, not_found}.
get(Pid, Key) ->
    call(Pid, {get, Key}).

%% Remove Key. Returns ok whether or not it existed.
%% This one is a CAST: fire-and-forget, no reply is awaited.
-spec delete(pid(), term()) -> ok.
delete(Pid, Key) ->
    cast(Pid, {delete, Key}).

%% Number of stored keys.
-spec size(pid()) -> non_neg_integer().
size(Pid) ->
    call(Pid, size).

%% Increment the integer stored under Key (treating a missing key as 0) and
%% return the new value.
-spec incr(pid(), term()) -> integer().
incr(Pid, Key) ->
    call(Pid, {incr, Key}).

%% --- the protocol: how the caller talks to the server process ---

%% Synchronous request: tag with a unique ref, send, wait for THAT reply.
%% The exit reasons it can raise -- {timeout, MFA} and {noproc, MFA} -- are
%% the same shapes gen_server:call produces, and you will read them in logs.
call(Pid, Request) ->
    %% Monitor the server for the duration of the call, exactly like
    %% gen_server:call does: if it is dead (or dies while we wait) we find out
    %% at once instead of waiting for the timeout.
    Mon = monitor(process, Pid),
    Ref = make_ref(),
    Pid ! {call, {self(), Ref}, Request},
    receive
        {Ref, Reply} ->
            demonitor(Mon, [flush]),
            Reply;
        {'DOWN', Mon, process, Pid, Reason} ->
            exit({Reason, {?MODULE, call, [Pid, Request]}})
    after ?TIMEOUT ->
        demonitor(Mon, [flush]),
        exit({timeout, {?MODULE, call, [Pid, Request]}})
    end.

%% Asynchronous request: just send. Always returns ok immediately.
cast(Pid, Request) ->
    Pid ! {cast, Request},
    ok.

%% --- the server side (runs in the spawned process) ---

%% Entry point: build the initial state, then enter the loop.
-spec init() -> ok.
init() ->
    loop(#{}).

%% The main loop. TODO: implement the three message kinds:
%%
%%   {call, {From, Ref}, stop}     -> reply ok to From, then RETURN (don't loop)
%%   {call, {From, Ref}, Request}  -> {Reply, NewState} = handle_call(Request, State),
%%                                    reply {Ref, Reply} to From, loop(NewState)
%%   {cast, Request}               -> NewState = handle_cast(Request, State),
%%                                    loop(NewState)
%%   anything else                 -> ignore it and loop(State)  (never crash
%%                                    on junk mail; gen_server does the same
%%                                    via handle_info)
loop(State) ->
    undefined.

%% Pure functions: Request + State in, Reply + NewState out.
%% TODO: implement every request listed in the API above.
-spec handle_call(term(), map()) -> {term(), map()}.
handle_call(Request, State) ->
    undefined.

-spec handle_cast(term(), map()) -> map().
handle_cast(Request, State) ->
    undefined.
