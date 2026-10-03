-module(receive_and_timeouts).

-export([rpc/2, rpc/3, flush/0, wait_for/2, start_server/0, stop_server/1]).
-export([server_loop/0]).

-spec rpc(pid(), term(), timeout()) -> term() | {error, timeout}.
rpc(Pid, Request, Timeout) ->
    Ref = make_ref(),
    Pid ! {call, self(), Ref, Request},
    receive
        {Ref, Reply} -> Reply
    after Timeout ->
        {error, timeout}
    end.

-spec rpc(pid(), term()) -> term() | {error, timeout}.
rpc(Pid, Request) ->
    rpc(Pid, Request, 1000).

-spec flush() -> [term()].
flush() ->
    receive
        Msg -> [Msg | flush()]
    after 0 ->
        []
    end.

-spec wait_for(atom(), timeout()) -> {ok, term()} | {error, timeout}.
wait_for(Tag, Timeout) ->
    receive
        {Tag, Value} -> {ok, Value}
    after Timeout ->
        {error, timeout}
    end.

%% --- A tiny server for the tests. ---

-spec start_server() -> pid().
start_server() ->
    spawn(?MODULE, server_loop, []).

-spec stop_server(pid()) -> stop.
stop_server(Pid) ->
    Pid ! stop.

-spec server_loop() -> ok.
server_loop() ->
    receive
        {call, From, Ref, {echo, X}} ->
            From ! {Ref, X},
            server_loop();
        {call, From, Ref, {sleep, Ms, X}} ->
            timer:sleep(Ms),
            From ! {Ref, X},
            server_loop();
        {call, _From, _Ref, ignore} ->
            server_loop();
        stop ->
            ok
    end.
