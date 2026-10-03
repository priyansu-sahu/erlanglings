%% I AM NOT DONE
-module(links_and_monitors_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').
-define(M, links_and_monitors).

%% `opaque/1` hides a value from the compiler's constant folding.
-export([opaque/1]).
opaque(X) -> X.

run_and_wait_test() ->
    ?assertEqual({ok, normal}, ?M:run_and_wait(fun() -> ok end)),
    ?assertMatch({crashed, {badarith, _}}, ?M:run_and_wait(fun() -> 1 / opaque(0) end)),
    ?assertEqual({crashed, boom}, ?M:run_and_wait(fun() -> exit(boom) end)),
    %% the test process itself must survive all of that
    ?assert(is_process_alive(self())).

exit_reason_via_link_test() ->
    ?assertEqual(normal, ?M:exit_reason_via_link(fun() -> ok end)),
    ?assertEqual(bye, ?M:exit_reason_via_link(fun() -> exit(bye) end)),
    ?assertMatch({{badmatch, 2}, _}, ?M:exit_reason_via_link(fun() -> 1 = opaque(2) end)),
    %% trap_exit was restored to false
    ?assertEqual({trap_exit, false}, process_info(self(), trap_exit)).

supervise_once_test() ->
    ?assertEqual({ok, first_try}, ?M:supervise_once(fun() -> ok end)),
    Counter = counters:new(1, []),
    FlakyOnce = fun() ->
                        counters:add(Counter, 1, 1),
                        case counters:get(Counter, 1) of
                            1 -> exit(first_run_fails);
                            _ -> ok
                        end
                end,
    ?assertEqual({ok, retried}, ?M:supervise_once(FlakyOnce)),
    ?assertEqual({error, gave_up, always}, ?M:supervise_once(fun() -> exit(always) end)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% A monitored process that simply returns: what Reason does 'DOWN' carry?
down_reason_normal_test() ->
    {Pid, Ref} = spawn_monitor(fun() -> ok end),
    receive {'DOWN', Ref, process, Pid, Reason} -> ?assertEqual(?TODO, Reason)
    after 500 -> error(no_down_message) end.

%% exit(Pid, kill) is the brutal kill. What reason does the monitor see?
%% (Hint: it is not `kill`.)
down_reason_killed_test() ->
    {Pid, Ref} = spawn_monitor(fun() -> receive never -> ok end end),
    exit(Pid, kill),
    receive {'DOWN', Ref, process, Pid, Reason} -> ?assertEqual(?TODO, Reason)
    after 500 -> error(no_down_message) end.

%% Monitoring a pid that is ALREADY dead delivers 'DOWN' right away. Reason?
monitor_dead_process_test() ->
    Pid = spawn(fun() -> ok end),
    receive after 20 -> ok end,
    Ref = monitor(process, Pid),
    receive {'DOWN', Ref, process, Pid, Reason} -> ?assertEqual(?TODO, Reason)
    after 500 -> error(no_down_message) end.

%% A linked process exiting with reason `normal` does NOT kill the linker.
%% Is the test process still alive after its linked child returns normally?
normal_exit_does_not_propagate_test() ->
    Pid = spawn_link(fun() -> ok end),
    receive after 20 -> ok end,
    ?assertEqual(?TODO, is_process_alive(Pid)),
    ?assertEqual(?TODO, is_process_alive(self())).

%% With trap_exit, a link's death becomes a message. Fill in the SHAPE of the
%% message for a child that calls exit(oops) -- use the variables Pid and
%% the atom you expect.
trap_exit_message_shape_test() ->
    OldFlag = process_flag(trap_exit, true),
    Pid = spawn_link(fun() -> exit(oops) end),
    Msg = receive M -> M after 500 -> error(no_exit_message) end,
    process_flag(trap_exit, OldFlag),
    ?assertEqual(?TODO, Msg).

%% exit/1 (one argument) raises an exception in the CURRENT process; it can be
%% caught. Which class? Fill in the class atom.
exit_one_is_an_exception_test() ->
    Class = try exit(opaque(stop)) catch C:_ -> C end,
    ?assertEqual(?TODO, Class).

%% demonitor with [flush] removes the monitor AND any 'DOWN' already queued.
%% How many messages are in the mailbox afterwards?
demonitor_flush_test() ->
    {Pid, Ref} = spawn_monitor(fun() -> ok end),
    receive after 20 -> ok end,          % let the 'DOWN' arrive
    true = demonitor(Ref, [flush]),
    _ = Pid,
    {message_queue_len, Len} = process_info(self(), message_queue_len),
    ?assertEqual(?TODO, Len).
