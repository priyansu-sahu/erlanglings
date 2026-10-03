-module(connection_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').
-define(IDLE_MS, 200).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% Do NOT modify connection.erl. Read it, then answer each question by
%% replacing ?TODO with the value you expect.

start() ->
    {ok, Pid} = connection:start_link(#{peer => <<"alice">>, idle_ms => ?IDLE_MS}),
    Pid.

stop(Pid) ->
    connection:stop(Pid).

connection_test_() ->
    {foreach, fun start/0, fun stop/1,
     [
      fun initial_state/1,
      fun send_while_disconnected/1,
      fun connect_twice/1,
      fun sequence_numbers/1,
      fun idle_timeout/1,
      fun activity_resets_idle_timer/1,
      fun seq_survives_reconnect/1,
      fun unknown_call/1,
      fun raw_state_shape/1
     ]}.

%% Q1. Which state does init/1 start in?
initial_state(Pid) ->
    ?_assertEqual(disconnected, connection:state(Pid)).

%% Q2. Find the clause of disconnected/3 that handles {send, _}.
send_while_disconnected(Pid) ->
    ?_assertEqual({error, disconnected}, connection:send(Pid, <<"hi">>)).

%% Q3. connect once, then connect again while connected.
connect_twice(Pid) ->
    fun() ->
        ?assertEqual(ok, connection:connect(Pid)),
        ?assertEqual(connected, connection:state(Pid)),
        ?assertEqual({error, already_connected}, connection:connect(Pid))
    end.

%% Q4. Two sends: what does each return? What does history/1 return
%%     (note the lists:reverse in handle_common)?
sequence_numbers(Pid) ->
    fun() ->
        ok = connection:connect(Pid),
        ?assertEqual({ok, 1}, connection:send(Pid, <<"a">>)),
        ?assertEqual({ok, 2}, connection:send(Pid, <<"b">>)),
        ?assertEqual([<<"a">>, <<"b">>], connection:history(Pid))
    end.

%% Q5. idle_ms is 200. We connect and then do nothing for 350 ms.
%%     Which clause fires, and which state are we in afterwards?
idle_timeout(Pid) ->
    {timeout, 5, fun() ->
        ok = connection:connect(Pid),
        timer:sleep(350),
        ?assertEqual(disconnected, connection:state(Pid))
    end}.

%% Q6. Connect, wait 120 ms, send, wait another 120 ms (240 ms total, more
%%     than idle_ms). Read the {send, _} clause of connected/3: what does
%%     setting state_timeout again do to the running timer? State now?
activity_resets_idle_timer(Pid) ->
    {timeout, 5, fun() ->
        ok = connection:connect(Pid),
        timer:sleep(120),
        {ok, _} = connection:send(Pid, <<"keepalive">>),
        timer:sleep(120),
        ?assertEqual(connected, connection:state(Pid))
    end}.

%% Q7. Send twice, disconnect, connect again, send. The state changed, but
%%     did `seq' in the data record get reset? (Where is seq set to 0?)
seq_survives_reconnect(Pid) ->
    fun() ->
        ok = connection:connect(Pid),
        {ok, 1} = connection:send(Pid, <<"a">>),
        {ok, 2} = connection:send(Pid, <<"b">>),
        ok = connection:disconnect(Pid),
        ok = connection:connect(Pid),
        ?assertEqual({ok, 3}, connection:send(Pid, <<"c">>))
    end.

%% Q8. A call no state function knows about. Trace it: connected/3's last
%%     clause -> handle_common/3 -> which clause?
unknown_call(Pid) ->
    ?_assertEqual({error, {unknown_event, reboot}}, gen_statem:call(Pid, reboot)).

%% Q9. For a gen_statem, sys:get_state/1 returns a 2-tuple {StateName, Data}.
%%     Data is a record. What is its record name (element 1 of Data)?
raw_state_shape(Pid) ->
    fun() ->
        {StateName, Data} = sys:get_state(Pid),
        ?assertEqual(disconnected, StateName),
        ?assertEqual(data, element(1, Data))
    end.
