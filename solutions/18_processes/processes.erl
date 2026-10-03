-module(processes).

-export([start_echo/0, echo/2, stop/1, parallel_map/2]).
%% internal export: spawn/3 needs to find echo_loop/0 by name
-export([echo_loop/0]).

-spec start_echo() -> pid().
start_echo() ->
    spawn(?MODULE, echo_loop, []).

-spec echo_loop() -> ok.
echo_loop() ->
    receive
        {From, Msg} ->
            From ! {self(), Msg},
            echo_loop();
        stop ->
            ok
    end.

-spec echo(pid(), term()) -> term().
echo(Pid, Msg) ->
    Pid ! {self(), Msg},
    receive
        {Pid, Reply} -> Reply
    end.

-spec stop(pid()) -> stop.
stop(Pid) ->
    Pid ! stop.

-spec parallel_map(fun((A) -> B), [A]) -> [B].
parallel_map(F, List) ->
    Parent = self(),
    Pids = [spawn(fun() -> Parent ! {self(), F(X)} end) || X <- List],
    [receive {Pid, Result} -> Result end || Pid <- Pids].
