-module(registered_processes).

-export([start/0, stop/0, increment/0, value/0, reset/0]).
-export([loop/1]).

-define(TIMEOUT, 1000).

-spec start() -> pid() | {error, already_started}.
start() ->
    case whereis(?MODULE) of
        undefined ->
            Pid = spawn(?MODULE, loop, [0]),
            true = register(?MODULE, Pid),
            Pid;
        _Pid ->
            {error, already_started}
    end.

-spec stop() -> ok.
stop() ->
    call(stop).

-spec increment() -> pos_integer().
increment() ->
    call(increment).

-spec value() -> non_neg_integer().
value() ->
    call(value).

-spec reset() -> ok.
reset() ->
    call(reset).

%% Send to the registered NAME; the reply comes back tagged with our ref.
call(Request) ->
    Ref = make_ref(),
    ?MODULE ! {self(), Ref, Request},
    receive
        {Ref, Reply} -> Reply
    after ?TIMEOUT ->
        exit({timeout, Request})
    end.

-spec loop(non_neg_integer()) -> ok.
loop(Count) ->
    receive
        {From, Ref, increment} ->
            From ! {Ref, Count + 1},
            loop(Count + 1);
        {From, Ref, value} ->
            From ! {Ref, Count},
            loop(Count);
        {From, Ref, reset} ->
            From ! {Ref, ok},
            loop(0);
        {From, Ref, stop} ->
            From ! {Ref, ok},
            ok
    end.
