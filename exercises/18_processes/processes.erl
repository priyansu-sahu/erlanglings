%% I AM NOT DONE
-module(processes).

-export([start_echo/0, echo/2, stop/1, parallel_map/2]).
%% Exported so spawn/3 can find it. In real code you'll see internal loop
%% functions exported with a comment like "%% internal export".
-export([echo_loop/0]).

%% Erlang processes are cheap, isolated, and talk ONLY by message passing.
%% The three primitives, which you will see thousands of times:
%%
%%   Pid = spawn(fun() -> ... end)      start a process; returns its pid
%%   Pid = spawn(Module, Function, Args) same, by name (survives code upgrades)
%%   Pid ! Message                      send (asynchronous, never fails, returns Message)
%%   receive
%%       Pattern1 -> ...;               wait for a message that MATCHES one of the
%%       Pattern2 -> ...                patterns. Non-matching messages stay in the
%%   end                                mailbox. Blocks forever if nothing matches.
%%
%% self() is the pid of the current process. The "request/reply" idiom is to
%% include self() in the message so the other side knows where to answer:
%%
%%   Pid ! {self(), Request},
%%   receive {Pid, Reply} -> Reply end
%%
%% A server is just a function that receives a message, acts, and calls
%% itself again (tail recursion = infinite loop with no stack growth).

%% Spawn an echo process running echo_loop/0 and return its pid.
%% Use spawn(?MODULE, echo_loop, []) so the loop is found by name.
-spec start_echo() -> pid().
start_echo() ->
    undefined.

%% The server loop. It must handle two messages:
%%   {From, Msg} -> send {self(), Msg} back to From, then loop again
%%   stop        -> return ok (the process ends when the function returns)
-spec echo_loop() -> ok.
echo_loop() ->
    undefined.

%% Send Msg to the echo process and wait for the reply. Return the echoed Msg.
-spec echo(pid(), term()) -> term().
echo(Pid, Msg) ->
    undefined.

%% Ask the echo process to stop.
-spec stop(pid()) -> stop.
stop(Pid) ->
    undefined.

%% Apply F to every element of List, each in its own process, and return the
%% results IN ORDER. Classic pattern:
%%   1. spawn one worker per element; each worker computes F(X) and sends
%%      {self(), Result} back to the parent;
%%   2. collect: for each worker pid, in order, receive {Pid, Result}.
%% Step 2 relies on selective receive -- receiving {Pid, _} for a specific Pid
%% leaves other workers' replies in the mailbox until their turn.
-spec parallel_map(fun((A) -> B), [A]) -> [B].
parallel_map(F, List) ->
    undefined.
