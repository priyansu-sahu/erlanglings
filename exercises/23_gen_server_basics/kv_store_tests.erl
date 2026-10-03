-module(kv_store_tests).

-include_lib("eunit/include/eunit.hrl").

%% A "fixture": start the server before the tests, stop it after.
%% You will see this {setup, Start, Stop, Tests} shape in most eunit suites.
kv_store_test_() ->
    {setup,
     fun() -> {ok, Pid} = kv_store:start_link(), Pid end,
     fun(_Pid) -> kv_store:stop() end,
     fun(_Pid) ->
         [
          ?_assertEqual(0, kv_store:size()),
          ?_assertEqual({error, not_found}, kv_store:get(name)),
          ?_assertEqual(ok, kv_store:put(name, <<"alice">>)),
          ?_assertEqual({ok, <<"alice">>}, kv_store:get(name)),
          ?_assertEqual(ok, kv_store:put(name, <<"bob">>)),
          ?_assertEqual({ok, <<"bob">>}, kv_store:get(name)),
          ?_assertEqual(ok, kv_store:put(age, 30)),
          ?_assertEqual(2, kv_store:size()),
          ?_assertEqual(ok, kv_store:delete(age)),
          %% delete/1 is a cast, but size/0 is a call. Messages from one
          %% process to another arrive in order, so by the time the call is
          %% handled the cast has already been processed.
          ?_assertEqual(1, kv_store:size()),
          ?_assertEqual({error, not_found}, kv_store:get(age)),
          %% Deleting a missing key is fine.
          ?_assertEqual(ok, kv_store:delete(nope)),
          ?_assertEqual(1, kv_store:size()),
          %% The catch-all clause must survive.
          ?_assertEqual({error, {unknown_call, bogus}},
                        gen_server:call(kv_store, bogus)),
          %% A raw message must not crash the server.
          ?_test(begin
                     kv_store ! garbage,
                     ?assertEqual(1, kv_store:size())
                 end)
         ]
     end}.
