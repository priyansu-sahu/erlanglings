-module(server_loop).

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

-spec put(pid(), term(), term()) -> ok.
put(Pid, Key, Value) ->
    call(Pid, {put, Key, Value}).

-spec get(pid(), term()) -> {ok, term()} | {error, not_found}.
get(Pid, Key) ->
    call(Pid, {get, Key}).

-spec delete(pid(), term()) -> ok.
delete(Pid, Key) ->
    cast(Pid, {delete, Key}).

-spec size(pid()) -> non_neg_integer().
size(Pid) ->
    call(Pid, size).

-spec incr(pid(), term()) -> integer().
incr(Pid, Key) ->
    call(Pid, {incr, Key}).

%% --- the protocol ---

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

cast(Pid, Request) ->
    Pid ! {cast, Request},
    ok.

%% --- the server side ---

-spec init() -> ok.
init() ->
    loop(#{}).

loop(State) ->
    receive
        {call, {From, Ref}, stop} ->
            From ! {Ref, ok},
            ok;
        {call, {From, Ref}, Request} ->
            {Reply, NewState} = handle_call(Request, State),
            From ! {Ref, Reply},
            loop(NewState);
        {cast, Request} ->
            NewState = handle_cast(Request, State),
            loop(NewState);
        _Junk ->
            loop(State)
    end.

-spec handle_call(term(), map()) -> {term(), map()}.
handle_call({put, Key, Value}, State) ->
    {ok, State#{Key => Value}};
handle_call({get, Key}, State) ->
    case maps:find(Key, State) of
        {ok, Value} -> {{ok, Value}, State};
        error -> {{error, not_found}, State}
    end;
handle_call(size, State) ->
    {maps:size(State), State};
handle_call({incr, Key}, State) ->
    New = maps:get(Key, State, 0) + 1,
    {New, State#{Key => New}}.

-spec handle_cast(term(), map()) -> map().
handle_cast({delete, Key}, State) ->
    maps:remove(Key, State).
