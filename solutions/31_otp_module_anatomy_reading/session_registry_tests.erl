-module(session_registry_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% Do NOT modify session_registry.erl. Each question names the part of the
%% module that answers it.

%%% ------------------------------------------------------------------
%%% Test helpers: fake session processes
%%% ------------------------------------------------------------------

%% A session process that registers itself when told to, and forwards any
%% {session_msg, _} it receives back to the test process.
spawn_session() ->
    Parent = self(),
    spawn(fun() -> session_loop(Parent) end).

session_loop(Parent) ->
    receive
        {register, UserId, DeviceId} ->
            Parent ! {registered, self(), session_registry:register(UserId, DeviceId)},
            session_loop(Parent);
        {session_msg, Msg} ->
            Parent ! {forwarded, self(), Msg},
            session_loop(Parent);
        stop ->
            ok
    end.

%% Ask a fake session to register and wait for the result.
register_from(Pid, UserId, DeviceId) ->
    Pid ! {register, UserId, DeviceId},
    receive {registered, Pid, Result} -> Result
    after 1000 -> error(no_reply_from_session)
    end.

%% Poll until Fun() is true (used where a 'DOWN' message must be processed).
wait_until(Fun) -> wait_until(Fun, 100).
wait_until(_Fun, 0) -> error(condition_never_became_true);
wait_until(Fun, N) ->
    case Fun() of
        true -> ok;
        false -> timer:sleep(10), wait_until(Fun, N - 1)
    end.

start() ->
    {ok, Pid} = session_registry:start_link(),
    Pid.

stop(_Pid) ->
    case whereis(session_registry) of
        undefined -> ok;
        _ -> session_registry:stop()
    end.

session_registry_test_() ->
    {foreach, fun start/0, fun stop/1,
     [
      fun empty_registry/1,
      fun register_self/1,
      fun several_devices/1,
      fun reregister_replaces/1,
      fun device_limit/1,
      fun dead_session_is_removed/1,
      fun unregister_keeps_process_alive/1,
      fun broadcast/1,
      fun unknown_call/1,
      fun table_facts/1,
      fun table_dies_with_server/1
     ]}.

%% Q1. Fresh registry. Read count/0 and lookup/1: what do they return
%%     when the table is empty?
empty_registry(_) ->
    fun() ->
        ?assertEqual(0, session_registry:count()),
        ?assertEqual([], session_registry:lookup(<<"alice">>))
    end.

%% Q2. register/2 registers the CALLING process. We call it from the test
%%     process itself. What does lookup/1 return? (self() is the test pid.)
register_self(_) ->
    fun() ->
        Me = self(),
        ?assertEqual(ok, session_registry:register(<<"alice">>, <<"phone">>)),
        ?assertEqual([{<<"phone">>, Me}], session_registry:lookup(<<"alice">>)),
        ?assertEqual(1, session_registry:count()),
        _ = Me
    end.

%% Q3. Two devices from two processes. lookup/1 sorts its result: in what
%%     order do the two devices come back? What does devices/1 return?
several_devices(_) ->
    fun() ->
        Phone = spawn_session(),
        Laptop = spawn_session(),
        ok = register_from(Phone, <<"alice">>, <<"phone">>),
        ok = register_from(Laptop, <<"alice">>, <<"laptop">>),
        ?assertEqual([{<<"laptop">>, Laptop}, {<<"phone">>, Phone}],
                     session_registry:lookup(<<"alice">>)),
        ?assertEqual([<<"laptop">>, <<"phone">>], session_registry:devices(<<"alice">>)),
        %% Other users are unaffected.
        ?assertEqual([], session_registry:lookup(<<"bob">>)),
        Phone ! stop, Laptop ! stop
    end.

%% Q4. The same device registers again from a NEW process (a reconnect).
%%     Read the first lines of handle_call({register, ...}): which pid is in
%%     the table afterwards, and how many rows are there?
reregister_replaces(_) ->
    fun() ->
        Old = spawn_session(),
        New = spawn_session(),
        ok = register_from(Old, <<"alice">>, <<"phone">>),
        ok = register_from(New, <<"alice">>, <<"phone">>),
        ?assertEqual([{<<"phone">>, New}], session_registry:lookup(<<"alice">>)),
        ?assertEqual(1, session_registry:count()),
        Old ! stop, New ! stop
    end.

%% Q5. ?MAX_DEVICES_PER_USER is 4. The fifth distinct device gets...?
%%     And does the failed attempt leave a row behind? (count/0)
device_limit(_) ->
    fun() ->
        Pids = [spawn_session() || _ <- lists:seq(1, 5)],
        Devices = [<<"d1">>, <<"d2">>, <<"d3">>, <<"d4">>, <<"d5">>],
        Results = [register_from(P, <<"alice">>, D) || {P, D} <- lists:zip(Pids, Devices)],
        ?assertEqual([ok, ok, ok, ok, {error, too_many_devices}], Results),
        ?assertEqual(4, session_registry:count()),
        [P ! stop || P <- Pids]
    end.

%% Q6. A registered session process dies. Read handle_info/2: what happens
%%     to its row? (wait_until is needed because the 'DOWN' message is
%%     asynchronous.) What does lookup return once it has been processed?
dead_session_is_removed(_) ->
    fun() ->
        Phone = spawn_session(),
        ok = register_from(Phone, <<"alice">>, <<"phone">>),
        ?assertEqual(1, session_registry:count()),
        exit(Phone, kill),
        wait_until(fun() -> session_registry:count() =:= 0 end),
        ?assertEqual([], session_registry:lookup(<<"alice">>))
    end.

%% Q7. unregister/2 is a cast. After it, is the session PROCESS still
%%     alive? (Does the registry ever kill anything?) And is the row gone?
%%     count/0 is a direct ETS read, so we first do a synchronous call
%%     (sys:get_state) to be sure the cast has been handled.
unregister_keeps_process_alive(_) ->
    fun() ->
        Phone = spawn_session(),
        ok = register_from(Phone, <<"alice">>, <<"phone">>),
        ok = session_registry:unregister(<<"alice">>, <<"phone">>),
        _ = sys:get_state(session_registry),
        ?assertEqual(true, is_process_alive(Phone)),
        ?assertEqual(0, session_registry:count()),
        Phone ! stop
    end.

%% Q8. broadcast/2 sends to every session of the user and returns a count.
%%     The fake sessions forward what they get as {forwarded, Pid, Msg}.
%%     What does broadcast return, and what exact message did each session
%%     process receive? (Read broadcast/2 and session_loop/1.)
broadcast(_) ->
    fun() ->
        Phone = spawn_session(),
        Laptop = spawn_session(),
        ok = register_from(Phone, <<"alice">>, <<"phone">>),
        ok = register_from(Laptop, <<"alice">>, <<"laptop">>),
        ?assertEqual(2, session_registry:broadcast(<<"alice">>, ping)),
        ?assertEqual(0, session_registry:broadcast(<<"nobody">>, ping)),
        Got = lists:sort([receive {forwarded, P, M} -> {P, M} after 1000 -> timeout end
                          || P <- [Phone, Laptop]]),
        ?assertEqual(lists:sort([{Phone, ping}, {Laptop, ping}]), Got),
        Phone ! stop, Laptop ! stop
    end.

%% Q9. The defensive catch-all in handle_call/3. (You will also see a
%%     warning logged: that is the ?LOG_WARNING line doing its job.)
unknown_call(_) ->
    ?_assertEqual({error, {unknown_call, dump}}, gen_server:call(session_registry, dump)).

%% Q10. Facts about the table, from init/1 and the -record(session, ...)
%%      definition. keypos is the tuple position of the key field: the
%%      record name is element 1, so `key' is element...? What is the
%%      protection level? Who owns the table (compare with whereis/1)?
table_facts(_) ->
    fun() ->
        ?assertEqual(2, ets:info(session_registry, keypos)),
        ?assertEqual(protected, ets:info(session_registry, protection)),
        ?assertEqual(true, ets:info(session_registry, owner) =:= whereis(session_registry))
    end.

%% Q11. Read terminate/2 and its comment. After the registry is stopped,
%%      what does ets:info/1 return for the table?
table_dies_with_server(_) ->
    fun() ->
        ok = session_registry:stop(),
        ?assertEqual(undefined, ets:info(session_registry))
    end.
