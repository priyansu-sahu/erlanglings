%% I AM NOT DONE
-module(receive_and_timeouts_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').
-define(M, receive_and_timeouts).

%% A fixture: start the server before each test, stop it after.
%% `{setup, Start, Stop, Instantiator}` is the eunit shape you will see most.
server_test_() ->
    {setup,
     fun() -> ?M:start_server() end,
     fun(Pid) -> ?M:stop_server(Pid) end,
     fun(Pid) ->
             [?_assertEqual(hello, ?M:rpc(Pid, {echo, hello})),
              ?_assertEqual(slow, ?M:rpc(Pid, {sleep, 20, slow}, 500)),
              ?_assertEqual({error, timeout}, ?M:rpc(Pid, ignore, 50)),
              ?_assertEqual({error, timeout}, ?M:rpc(Pid, {sleep, 200, late}, 20)),
              %% a late reply must not confuse the NEXT call: refs are unique
              ?_assertEqual(fresh, ?M:rpc(Pid, {echo, fresh}, 500))]
     end}.

flush_test() ->
    self() ! one,
    self() ! two,
    self() ! three,
    ?assertEqual([one, two, three], ?M:flush()),
    ?assertEqual([], ?M:flush()).

wait_for_test() ->
    self() ! {other, 1},
    self() ! {wanted, 42},
    self() ! {other, 2},
    ?assertEqual({ok, 42}, ?M:wait_for(wanted, 100)),
    %% the two `other` messages are still there, in order
    ?assertEqual([{other, 1}, {other, 2}], ?M:flush()),
    ?assertEqual({error, timeout}, ?M:wait_for(wanted, 20)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% `after 0` with an empty mailbox returns immediately. What is R?
after_zero_empty_test() ->
    R = receive _ -> got_something after 0 -> nothing end,
    ?assertEqual(?TODO, R).

%% The after clause runs only if NO pattern matched within the timeout.
%% The mailbox has `a`; we wait for `b`. What is R?
after_fires_when_no_match_test() ->
    self() ! a,
    R = receive b -> got_b after 10 -> timed_out end,
    ?assertEqual(?TODO, R),
    %% ...and `a` is still in the mailbox afterwards. What does flush return?
    ?assertEqual(?TODO, ?M:flush()).

%% A reference from make_ref() is unique. Two refs compare equal?
make_ref_unique_test() ->
    ?assertEqual(?TODO, make_ref() =:= make_ref()).

%% A reply tagged with an OLD ref is never matched by a receive waiting on a
%% NEW ref. How many messages are left in the mailbox after this?
stale_reply_ignored_test() ->
    OldRef = make_ref(),
    NewRef = make_ref(),
    self() ! {OldRef, stale},
    self() ! {NewRef, fresh},
    Got = receive {NewRef, V} -> V after 10 -> timeout end,
    ?assertEqual(?TODO, Got),
    ?assertEqual(?TODO, length(?M:flush())).

%% A receive with NO patterns and only an after clause is legal: it is how
%% `sleep` was written before timer:sleep/1 existed, and you still see it.
%% What does it evaluate to?
receive_as_sleep_test() ->
    ?assertEqual(?TODO, receive after 5 -> slept end).
