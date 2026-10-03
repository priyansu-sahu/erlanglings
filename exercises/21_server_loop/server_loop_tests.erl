%% I AM NOT DONE
-module(server_loop_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').
-define(M, server_loop).

%% One fixture, one server per test. `foreach` runs Setup/Cleanup around EACH
%% test in the list (compare `setup`, which runs them once around all tests).
store_test_() ->
    {foreach,
     fun() -> ?M:start() end,
     fun(Pid) -> ?M:stop(Pid), wait_for_exit(Pid) end,
     [fun put_and_get/1,
      fun missing_key/1,
      fun overwrite/1,
      fun delete_is_async/1,
      fun size_counts_keys/1,
      fun incr/1,
      fun junk_mail_is_ignored/1]}.

put_and_get(Pid) ->
    fun() ->
            ?assertEqual(ok, ?M:put(Pid, name, <<"ann">>)),
            ?assertEqual({ok, <<"ann">>}, ?M:get(Pid, name))
    end.

missing_key(Pid) ->
    ?_assertEqual({error, not_found}, ?M:get(Pid, nope)).

overwrite(Pid) ->
    fun() ->
            ok = ?M:put(Pid, k, 1),
            ok = ?M:put(Pid, k, 2),
            ?assertEqual({ok, 2}, ?M:get(Pid, k)),
            ?assertEqual(1, ?M:size(Pid))
    end.

delete_is_async(Pid) ->
    fun() ->
            ok = ?M:put(Pid, k, 1),
            ?assertEqual(ok, ?M:delete(Pid, k)),
            %% a later CALL is guaranteed to be handled after the earlier cast
            %% (same sender, same receiver => in order), so this is safe:
            ?assertEqual({error, not_found}, ?M:get(Pid, k)),
            ?assertEqual(ok, ?M:delete(Pid, never_existed))
    end.

size_counts_keys(Pid) ->
    fun() ->
            ?assertEqual(0, ?M:size(Pid)),
            ok = ?M:put(Pid, a, 1),
            ok = ?M:put(Pid, b, 2),
            ?assertEqual(2, ?M:size(Pid))
    end.

incr(Pid) ->
    fun() ->
            ?assertEqual(1, ?M:incr(Pid, hits)),
            ?assertEqual(2, ?M:incr(Pid, hits)),
            ok = ?M:put(Pid, base, 10),
            ?assertEqual(11, ?M:incr(Pid, base))
    end.

junk_mail_is_ignored(Pid) ->
    fun() ->
            Pid ! garbage,
            Pid ! {call, nonsense},
            ?assertEqual(ok, ?M:put(Pid, still, alive)),
            ?assert(is_process_alive(Pid))
    end.

stop_test() ->
    Pid = ?M:start(),
    ?assertEqual(ok, ?M:stop(Pid)),
    wait_for_exit(Pid),
    ?assertNot(is_process_alive(Pid)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% handle_call/2 is a PURE function: no process involved. Once you have
%% implemented it, you can predict its results by reading it. {Reply, NewState}:
pure_handle_call_test() ->
    ?assertEqual(?TODO, ?M:handle_call({get, k}, #{k => 1})),
    ?assertEqual(?TODO, ?M:handle_call({put, k, 2}, #{})),
    ?assertEqual(?TODO, ?M:handle_call(size, #{a => 1, b => 2})),
    ?assertEqual(?TODO, ?M:handle_call({incr, n}, #{})).

%% handle_cast/2 returns only the new state.
pure_handle_cast_test() ->
    ?assertEqual(?TODO, ?M:handle_cast({delete, k}, #{k => 1, j => 2})).

%% Two servers, two states. After putting into A only, what does get on B return?
state_is_per_process_test() ->
    A = ?M:start(),
    B = ?M:start(),
    ok = ?M:put(A, k, 1),
    R = ?M:get(B, k),
    ?M:stop(A), ?M:stop(B),
    ?assertEqual(?TODO, R).

%% cast/2 returns before the server has done anything. What does delete/2
%% return, regardless of whether the key existed?
cast_returns_immediately_test() ->
    Pid = ?M:start(),
    R = ?M:delete(Pid, anything),
    ?M:stop(Pid),
    ?assertEqual(?TODO, R).

%% The wire format. A call message as seen in the server's mailbox has the
%% form {call, {FromPid, Ref}, Request}. Send one by hand to the test process
%% (pretending we are a client) and look at it. What is element(1, Msg)?
wire_format_test() ->
    Ref = make_ref(),
    self() ! {call, {self(), Ref}, {get, k}},
    Msg = receive X -> X end,
    ?assertEqual(?TODO, element(1, Msg)),
    ?assertEqual(?TODO, tuple_size(Msg)).

%% --- helpers ---

wait_for_exit(Pid) ->
    Ref = monitor(process, Pid),
    receive {'DOWN', Ref, process, Pid, _} -> ok after 1000 -> error(timeout) end.
