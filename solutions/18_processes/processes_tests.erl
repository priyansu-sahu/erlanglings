-module(processes_tests).

-include_lib("eunit/include/eunit.hrl").

echo_test() ->
    Pid = processes:start_echo(),
    ?assert(is_pid(Pid)),
    ?assert(is_process_alive(Pid)),
    ?assertEqual(hello, processes:echo(Pid, hello)),
    ?assertEqual({complex, [1, 2, 3]}, processes:echo(Pid, {complex, [1, 2, 3]})),
    processes:stop(Pid),
    wait_for_exit(Pid),
    ?assertNot(is_process_alive(Pid)).

two_echo_servers_are_independent_test() ->
    A = processes:start_echo(),
    B = processes:start_echo(),
    ?assertNotEqual(A, B),
    ?assertEqual(from_a, processes:echo(A, from_a)),
    ?assertEqual(from_b, processes:echo(B, from_b)),
    processes:stop(A),
    processes:stop(B),
    wait_for_exit(A),
    wait_for_exit(B).

parallel_map_test() ->
    ?assertEqual([1, 4, 9, 16], processes:parallel_map(fun(X) -> X * X end, [1, 2, 3, 4])),
    ?assertEqual([], processes:parallel_map(fun(X) -> X end, [])),
    %% Results come back in list order even if the first element is slowest.
    Slow = fun(X) -> timer:sleep(X), X end,
    ?assertEqual([60, 1, 30], processes:parallel_map(Slow, [60, 1, 30])).

parallel_map_is_parallel_test() ->
    %% 10 workers each sleeping 50ms must finish well under 10 * 50ms.
    {Micros, _} = timer:tc(fun() ->
                                   processes:parallel_map(fun(X) -> timer:sleep(50), X end,
                                                          lists:seq(1, 10))
                           end),
    ?assert(Micros < 300_000).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% `!` returns the message that was sent.
send_returns_message_test() ->
    ?assertEqual({hi, there}, self() ! {hi, there}),
    receive {hi, there} -> ok end.

%% A spawned process has a different pid from its parent.
spawn_returns_new_pid_test() ->
    Pid = spawn(fun() -> ok end),
    ?assertEqual(false, Pid =:= self()),
    ?assertEqual(true, is_pid(Pid)).

%% Messages from ONE sender to ONE receiver arrive in the order sent.
%% What does the receiving side collect?
message_order_test() ->
    Self = self(),
    spawn(fun() -> Self ! first, Self ! second, Self ! third end),
    Collected = [receive M -> M end || _ <- [1, 2, 3]],
    ?assertEqual([first, second, third], Collected).

%% receive only takes a message that MATCHES. Non-matching messages wait in
%% the mailbox. With `a` and `b` in the mailbox, we first receive `b`.
%% Which message does the second receive get?
selective_receive_test() ->
    self() ! a,
    self() ! b,
    receive b -> ok end,
    Next = receive M -> M end,
    ?assertEqual(a, Next).

%% A process that finishes its function is gone. is_process_alive after it
%% has returned is...
process_ends_when_function_returns_test() ->
    Pid = spawn(fun() -> ok end),
    wait_for_exit(Pid),
    ?assertEqual(false, is_process_alive(Pid)).

%% Sending to a pid that no longer exists does not raise. What does `!` return?
send_to_dead_pid_test() ->
    Pid = spawn(fun() -> ok end),
    wait_for_exit(Pid),
    ?assertEqual(ignored, Pid ! ignored).

%% --- helpers ---

wait_for_exit(Pid) ->
    Ref = monitor(process, Pid),
    receive {'DOWN', Ref, process, Pid, _} -> ok after 1000 -> error(timeout) end.
