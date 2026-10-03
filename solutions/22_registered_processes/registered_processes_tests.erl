-module(registered_processes_tests).

-include_lib("eunit/include/eunit.hrl").

-define(M, registered_processes).

counter_test_() ->
    {foreach,
     fun() -> Pid = ?M:start(), true = is_pid(Pid), Pid end,
     fun(Pid) -> ?M:stop(), wait_for_exit(Pid) end,
     [fun starts_at_zero/1,
      fun increments/1,
      fun resets/1,
      fun reachable_by_name/1,
      fun only_one_instance/1]}.

starts_at_zero(_) ->
    ?_assertEqual(0, ?M:value()).

increments(_) ->
    fun() ->
            ?assertEqual(1, ?M:increment()),
            ?assertEqual(2, ?M:increment()),
            ?assertEqual(3, ?M:increment()),
            ?assertEqual(3, ?M:value())
    end.

resets(_) ->
    fun() ->
            1 = ?M:increment(),
            ?assertEqual(ok, ?M:reset()),
            ?assertEqual(0, ?M:value())
    end.

reachable_by_name(Pid) ->
    fun() ->
            ?assertEqual(Pid, whereis(registered_processes)),
            ?assert(lists:member(registered_processes, registered()))
    end.

only_one_instance(Pid) ->
    fun() ->
            ?assertEqual({error, already_started}, ?M:start()),
            %% ...and the original is still the one registered
            ?assertEqual(Pid, whereis(registered_processes))
    end.

name_is_freed_on_stop_test() ->
    Pid = ?M:start(),
    ok = ?M:stop(),
    wait_for_exit(Pid),
    ?assertEqual(undefined, whereis(registered_processes)),
    %% and a new one can start
    Pid2 = ?M:start(),
    ?assert(is_pid(Pid2)),
    ?assertNotEqual(Pid, Pid2),
    ok = ?M:stop(),
    wait_for_exit(Pid2).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% whereis/1 for a name nobody registered.
whereis_unknown_test() ->
    ?assertEqual(undefined, whereis(no_such_process_name)).

%% Sending to an UNREGISTERED name is an error (contrast: sending to a dead
%% pid is silently fine). Fill in the error reason.
send_to_unknown_name_test() ->
    ?assertError(badarg, no_such_process_name ! hello).

%% Registering a name that is already taken. Fill in the error reason.
register_twice_test() ->
    Pid = spawn(fun() -> receive stop -> ok end end),
    true = register(erlanglings_tmp_name, Pid),
    Result = try register(erlanglings_tmp_name, self())
             catch error:Reason -> {error, Reason}
             end,
    Pid ! stop,
    wait_for_exit(Pid),
    ?assertEqual({error, badarg}, Result).

%% register/2 returns... (look at how the fixture above uses it)
register_return_value_test() ->
    Pid = spawn(fun() -> receive stop -> ok end end),
    R = register(erlanglings_tmp_name2, Pid),
    Pid ! stop,
    wait_for_exit(Pid),
    ?assertEqual(true, R).

%% When a registered process dies, its name is released automatically.
%% After the spawned process exits, whereis/1 returns...
name_released_on_death_test() ->
    Pid = spawn(fun() -> receive stop -> ok end end),
    true = register(erlanglings_tmp_name3, Pid),
    Pid ! stop,
    wait_for_exit(Pid),
    ?assertEqual(undefined, whereis(erlanglings_tmp_name3)).

%% Some well-known names are always registered in a running VM. Is the code
%% server (`code_server`) among registered()?
well_known_names_test() ->
    ?assertEqual(true, lists:member(code_server, registered())).

%% --- helpers ---

wait_for_exit(Pid) ->
    Ref = monitor(process, Pid),
    receive {'DOWN', Ref, process, Pid, _} -> ok after 1000 -> error(timeout) end.
