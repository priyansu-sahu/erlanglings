%% I AM NOT DONE
-module(receive_and_timeouts).

-export([rpc/2, rpc/3, flush/0, wait_for/2, start_server/0, stop_server/1]).
-export([server_loop/0]).

%% `receive` with a timeout:
%%
%%   receive
%%       Pattern -> ...
%%   after Timeout ->          % milliseconds, or the atom `infinity`
%%       timed_out
%%   end
%%
%% `after 0` is a special case: check the mailbox and return immediately if
%% nothing matches. You will see it used to drain a mailbox, or to "peek".
%%
%% The reference trick. If a process sends two requests to the same server,
%% how does it tell the replies apart? With a unique reference:
%%
%%   Ref = make_ref(),
%%   Pid ! {call, self(), Ref, Request},
%%   receive
%%       {Ref, Reply} -> Reply          % only THIS request's reply matches
%%   after 5000 ->
%%       exit(timeout)
%%   end
%%
%% This is exactly what gen_server:call/3 does under the hood (plus a monitor
%% so a dead server is detected immediately rather than after the timeout).
%% When you read "{'$gen_call', {Pid, Ref}, Request}" in a crash log, that's it.

%% Send {call, self(), Ref, Request} to Pid and wait for {Ref, Reply}.
%% Return Reply, or {error, timeout} after Timeout milliseconds.
-spec rpc(pid(), term(), timeout()) -> term() | {error, timeout}.
rpc(Pid, Request, Timeout) ->
    undefined.

%% Same with a default timeout of 1000 ms.
-spec rpc(pid(), term()) -> term() | {error, timeout}.
rpc(Pid, Request) ->
    rpc(Pid, Request, 1000).

%% Remove every message from the current process's mailbox and return them
%% as a list, oldest first. Use `receive ... after 0`.
-spec flush() -> [term()].
flush() ->
    undefined.

%% Wait up to Timeout ms for a message of the form {Tag, Value} and return
%% {ok, Value}. Messages with OTHER tags must be left in the mailbox.
%% On timeout return {error, timeout}.
-spec wait_for(atom(), timeout()) -> {ok, term()} | {error, timeout}.
wait_for(Tag, Timeout) ->
    undefined.

%% --- A tiny server for the tests. Already implemented; read it. ---

-spec start_server() -> pid().
start_server() ->
    spawn(?MODULE, server_loop, []).

-spec stop_server(pid()) -> stop.
stop_server(Pid) ->
    Pid ! stop.

%% Handles the {call, From, Ref, Request} protocol:
%%   {echo, X}         -> replies X
%%   {sleep, Ms, X}    -> waits Ms, then replies X
%%   ignore            -> never replies (so callers time out)
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
