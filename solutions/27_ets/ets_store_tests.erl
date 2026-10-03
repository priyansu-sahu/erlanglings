-module(ets_store_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% Each test gets a fresh table. The table is owned by the test process and
%% deleted when that process exits, so no cleanup is needed.
with_table(TestFun) ->
    fun() ->
        Tab = ets_store:new(),
        TestFun(Tab)
    end.

ets_store_test_() ->
    [
     with_table(fun put_and_get/1),
     with_table(fun overwrite/1),
     with_table(fun incr/1),
     with_table(fun keys_and_delete/1),
     with_table(fun older_than/1)
    ].

put_and_get(Tab) ->
    ?assertEqual(not_found, ets_store:get(Tab, user1)),
    ?assertEqual(ok, ets_store:put(Tab, user1, <<"alice">>)),
    ?assertEqual({ok, <<"alice">>}, ets_store:get(Tab, user1)).

overwrite(Tab) ->
    ok = ets_store:put(Tab, k, 1),
    ok = ets_store:put(Tab, k, 2),
    ?assertEqual({ok, 2}, ets_store:get(Tab, k)),
    ?assertEqual(1, ets:info(Tab, size)).

incr(Tab) ->
    ?assertEqual(1, ets_store:incr(Tab, hits)),
    ?assertEqual(2, ets_store:incr(Tab, hits)),
    ?assertEqual(3, ets_store:incr(Tab, hits)),
    ?assertEqual(1, ets_store:incr(Tab, misses)),
    ?assertEqual({ok, 3}, ets_store:get(Tab, hits)).

keys_and_delete(Tab) ->
    ok = ets_store:put(Tab, c, 3),
    ok = ets_store:put(Tab, a, 1),
    ok = ets_store:put(Tab, b, 2),
    ?assertEqual([a, b, c], ets_store:keys(Tab)),
    ?assertEqual(ok, ets_store:delete(Tab, b)),
    ?assertEqual(ok, ets_store:delete(Tab, does_not_exist)),
    ?assertEqual([a, c], ets_store:keys(Tab)).

older_than(Tab) ->
    ok = ets_store:put(Tab, s1, 1000),
    ok = ets_store:put(Tab, s2, 2000),
    ok = ets_store:put(Tab, s3, 3000),
    ?assertEqual([s1, s2], ets_store:older_than(Tab, 2500)),
    ?assertEqual([], ets_store:older_than(Tab, 1000)),
    ?assertEqual([s1, s2, s3], ets_store:older_than(Tab, 9999)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

reading_test_() ->
    [
     %% Q1. ets:lookup/2 on a key that is not there. (Not an error!)
     fun() ->
         T = ets:new(q1, [set]),
         ?assertEqual([], ets:lookup(T, missing))
     end,

     %% Q2. In a `set', inserting a row with an existing key REPLACES it.
     %%     What does lookup return now?
     fun() ->
         T = ets:new(q2, [set]),
         true = ets:insert(T, {k, 1}),
         true = ets:insert(T, {k, 2}),
         ?assertEqual([{k, 2}], ets:lookup(T, k))
     end,

     %% Q3. Same thing in a `bag': several rows per key are kept.
     %%     How many rows does lookup return? (length)
     fun() ->
         T = ets:new(q3, [bag]),
         true = ets:insert(T, {k, 1}),
         true = ets:insert(T, {k, 2}),
         true = ets:insert(T, {k, 2}),  % exact duplicate: bag drops it
         ?assertEqual(2, length(ets:lookup(T, k)))
     end,

     %% Q4. ets:match/2 returns the bound '$N' variables of each row, but
     %%     each row's variables come wrapped in a LIST. With one variable
     %%     you get a list of one-element lists. (Sorted here for stability.)
     fun() ->
         T = ets:new(q4, [set]),
         true = ets:insert(T, [{a, 1}, {b, 2}]),
         ?assertEqual([[a], [b]], lists:sort(ets:match(T, {'$1', '_'})))
     end,

     %% Q5. ets:select/2 with a match spec returning a tuple of two vars.
     fun() ->
         T = ets:new(q5, [set]),
         true = ets:insert(T, [{a, 1}, {b, 2}, {c, 3}]),
         MS = [{{'$1', '$2'}, [{'>', '$2', 1}], [{{'$2', '$1'}}]}],
         ?assertEqual([{2, b}, {3, c}], lists:sort(ets:select(T, MS)))
     end,

     %% Q6. ordered_set keeps rows sorted by key; tab2list returns them in
     %%     key order. (For `set' the order is unspecified: never rely on it.)
     fun() ->
         T = ets:new(q6, [ordered_set]),
         true = ets:insert(T, [{3, c}, {1, a}, {2, b}]),
         ?assertEqual([{1, a}, {2, b}, {3, c}], ets:tab2list(T))
     end,

     %% Q7. A table dies with its owner. The spawned process creates a table
     %%     and exits. What does ets:info/1 return for a deleted table?
     fun() ->
         Parent = self(),
         Pid = spawn(fun() ->
                         T = ets:new(q7, [set, public]),
                         Parent ! {table, T}
                     end),
         T = receive {table, Tab} -> Tab after 1000 -> error(no_table) end,
         Ref = monitor(process, Pid),
         receive {'DOWN', Ref, process, Pid, _} -> ok after 1000 -> error(still_alive) end,
         ?assertEqual(undefined, ets:info(T))
     end,

     %% Q8. A named_table can be addressed by its atom name. What does
     %%     ets:new/2 return when named_table is given? (Compare: without
     %%     named_table it returns an opaque reference.)
     fun() ->
         Ret = ets:new(q8_named, [set, named_table]),
         true = ets:insert(q8_named, {x, 1}),
         ?assertEqual(q8_named, Ret),
         ?assertEqual([{x, 1}], ets:lookup(q8_named, x)),
         true = ets:delete(q8_named)
     end
    ].
