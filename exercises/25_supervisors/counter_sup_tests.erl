%% I AM NOT DONE
-module(counter_sup_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

start() ->
    {ok, Sup} = counter_sup:start_link(),
    %% start_link links the supervisor to THIS test process. Unlink so that
    %% shutting it down in cleanup does not take the test runner with it.
    true = unlink(Sup),
    Sup.

stop(Sup) ->
    Ref = monitor(process, Sup),
    exit(Sup, shutdown),
    receive {'DOWN', Ref, process, Sup, _} -> ok after 1000 -> error(sup_did_not_stop) end.

%% Poll until the registered name points at a pid different from OldPid.
wait_for_restart(OldPid) ->
    wait_for_restart(OldPid, 50).

wait_for_restart(_OldPid, 0) ->
    error(child_not_restarted);
wait_for_restart(OldPid, N) ->
    case whereis(counter_worker) of
        Pid when is_pid(Pid), Pid =/= OldPid -> Pid;
        _ -> timer:sleep(10), wait_for_restart(OldPid, N - 1)
    end.

counter_sup_test_() ->
    {foreach, fun start/0, fun stop/1,
     [
      fun child_is_started/1,
      fun child_shape/1,
      fun restart_after_crash/1,
      fun restart_after_kill/1,
      fun restart_after_normal_exit/1,
      fun flags_and_spec/1
     ]}.

%% The supervisor must start counter_worker as its child.
child_is_started(_Sup) ->
    fun() ->
        ?assert(is_pid(whereis(counter_worker))),
        ?assertEqual(0, counter_worker:value())
    end.

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Q1. supervisor:which_children/1 returns one tuple per child:
%%       {Id, ChildPid, Type, Modules}
%%     What are Id, Type and Modules for our child? (Look at child_spec/0.)
%%     supervisor:count_children/1 returns a proplist; what is `workers'?
child_shape(Sup) ->
    fun() ->
        [{Id, Pid, Type, Modules}] = supervisor:which_children(Sup),
        ?assert(is_pid(Pid)),
        ?assertEqual(?TODO, Id),
        ?assertEqual(?TODO, Type),
        ?assertEqual(?TODO, Modules),
        Counts = supervisor:count_children(Sup),
        ?assertEqual(?TODO, proplists:get_value(workers, Counts))
    end.

%% Q2. We increment twice, then make the worker crash. The supervisor
%%     restarts it. What does value/0 return on the NEW process? (Where did
%%     the state live?)
restart_after_crash(_Sup) ->
    fun() ->
        OldPid = whereis(counter_worker),
        counter_worker:incr(),
        counter_worker:incr(),
        ?assertEqual(2, counter_worker:value()),
        counter_worker:crash(),
        NewPid = wait_for_restart(OldPid),
        ?assertNotEqual(OldPid, NewPid),
        ?assertEqual(?TODO, counter_worker:value())
    end.

%% Q3. exit(Pid, kill) is an untrappable kill from outside. Does the
%%     supervisor restart a killed child? (true/false: is there a live
%%     registered counter_worker afterwards?)
restart_after_kill(_Sup) ->
    fun() ->
        OldPid = whereis(counter_worker),
        exit(OldPid, kill),
        _ = wait_for_restart(OldPid),
        ?assertEqual(?TODO, is_pid(whereis(counter_worker)))
    end.

%% Q4. counter_worker:stop/0 exits with reason `normal'. The child spec says
%%     restart => permanent. Is the child restarted after a NORMAL exit?
%%     (Look up what permanent / transient / temporary mean in the README.)
restart_after_normal_exit(_Sup) ->
    fun() ->
        OldPid = whereis(counter_worker),
        ok = counter_worker:stop(),
        Restarted = try wait_for_restart(OldPid) of
                        _ -> true
                    catch error:child_not_restarted -> false
                    end,
        ?assertEqual(?TODO, Restarted)
    end.

%% Your init/1 must use one_for_one with intensity 5 / period 10, and the
%% child spec from counter_worker:child_spec/0.
flags_and_spec(Sup) ->
    fun() ->
        {ok, Spec} = supervisor:get_childspec(Sup, counter_worker),
        ?assertEqual(permanent, maps:get(restart, Spec)),
        ?assertEqual({counter_worker, start_link, []}, maps:get(start, Spec)),
        %% The flags are not directly readable, but the strategy shows in the
        %% supervisor's state (a record). We just check it is a one_for_one.
        State = sys:get_state(Sup),
        ?assert(lists:member(one_for_one, tuple_to_list(State)))
    end.
