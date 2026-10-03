-module(rate_limiter_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% Do NOT modify rate_limiter.erl. Read it, then answer each question by
%% replacing ?TODO with the value you expect. Run the exercise to check.

start() ->
    %% A small limit and a short window so the tests run fast.
    {ok, Pid} = rate_limiter:start_link(#{limit => 3, refill_ms => 50}),
    Pid.

stop(Pid) ->
    rate_limiter:stop(Pid).

rate_limiter_test_() ->
    {foreach, fun start/0, fun stop/1,
     [
      fun fresh_key/1,
      fun consume_tokens/1,
      fun keys_are_independent/1,
      fun unknown_call/1,
      fun reset_is_a_cast/1,
      fun refill_timer/1,
      fun stray_messages/1,
      fun peek_at_state/1
     ]}.

%% Q1. `alice' has never been seen. Read tokens_left/2: how many tokens does
%% a never-seen key have?
fresh_key(Pid) ->
    ?_assertEqual(3, rate_limiter:remaining(Pid, alice)).

%% Q2. Three allows succeed, then what does the fourth return?
%% And what does remaining/2 say afterwards?
consume_tokens(Pid) ->
    fun() ->
        ok = rate_limiter:allow(Pid, alice),
        ok = rate_limiter:allow(Pid, alice),
        ok = rate_limiter:allow(Pid, alice),
        ?assertEqual({error, rate_limited}, rate_limiter:allow(Pid, alice)),
        ?assertEqual(0, rate_limiter:remaining(Pid, alice))
    end.

%% Q3. Exhausting alice's bucket: does it affect bob?
keys_are_independent(Pid) ->
    fun() ->
        _ = [rate_limiter:allow(Pid, alice) || _ <- lists:seq(1, 5)],
        ?assertEqual(3, rate_limiter:remaining(Pid, bob))
    end.

%% Q4. gen_server:call with a request no clause expects. Which clause of
%% handle_call/3 runs, and what is the reply?
unknown_call(Pid) ->
    ?_assertEqual({error, {unknown_call, flush_everything}}, gen_server:call(Pid, flush_everything)).

%% Q5. reset/1 is a cast (asynchronous). Immediately after it we do a call.
%% Can the call observe the state from BEFORE the reset? (Think about message
%% ordering between two processes.)
reset_is_a_cast(Pid) ->
    fun() ->
        ok = rate_limiter:allow(Pid, alice),
        ok = rate_limiter:allow(Pid, alice),
        ?assertEqual(ok, rate_limiter:reset(Pid)),  % what does cast return?
        ?assertEqual(3, rate_limiter:remaining(Pid, alice))
    end.

%% Q6. The window is 50 ms. After using all tokens and waiting 150 ms, how
%% many tokens does alice have? Which callback made that happen?
refill_timer(Pid) ->
    {timeout, 5, fun() ->
        _ = [rate_limiter:allow(Pid, alice) || _ <- lists:seq(1, 3)],
        ?assertEqual(0, rate_limiter:remaining(Pid, alice)),
        timer:sleep(150),
        ?assertEqual(3, rate_limiter:remaining(Pid, alice))
    end}.

%% Q7. Someone sends the server a raw message it does not understand.
%% Is the process still alive afterwards?
stray_messages(Pid) ->
    fun() ->
        Pid ! {unexpected, garbage},
        _ = sys:get_state(Pid),   % a synchronous call; forces the ! to be processed first
        ?assertEqual(true, is_process_alive(Pid))
    end.

%% Q8. sys:get_state/1 returns the server's current state term. This is
%% a very handy tool when reading unfamiliar code in a live shell.
%% The state is a record. Records are tuples whose first element is the
%% record name. What is element 1 of the state? How many elements does
%% the tuple have (record name + fields)?
peek_at_state(Pid) ->
    fun() ->
        State = sys:get_state(Pid),
        ?assertEqual(state, element(1, State)),
        ?assertEqual(5, tuple_size(State))
    end.
