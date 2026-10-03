-module(lists_module_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

-define(USERS, [{<<"ann">>, 31}, {<<"bob">>, 25}, {<<"cid">>, 47}]).

doubles_test() ->
    ?assertEqual([2, 4, 6], lists_module:doubles([1, 2, 3])).

evens_test() ->
    ?assertEqual([2, 4], lists_module:evens([1, 2, 3, 4, 5])).

total_test() ->
    ?assertEqual(0, lists_module:total([])),
    ?assertEqual(6, lists_module:total([1, 2, 3])).

names_test() ->
    ?assertEqual([<<"ann">>, <<"bob">>, <<"cid">>], lists_module:names(?USERS)).

oldest_test() ->
    ?assertEqual(<<"cid">>, lists_module:oldest(?USERS)).

by_name_test() ->
    ?assertEqual({ok, 25}, lists_module:by_name(<<"bob">>, ?USERS)),
    ?assertEqual(error, lists_module:by_name(<<"zed">>, ?USERS)).

word_lengths_test() ->
    ?assertEqual([{"hi", 2}, {"there", 5}], lists_module:word_lengths(["hi", "there"])).

top_n_test() ->
    ?assertEqual([9, 5], lists_module:top_n(2, [5, 1, 9, 3])),
    ?assertEqual([3, 1], lists_module:top_n(5, [1, 3])).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% foldl calls F(Elem, Acc). This one conses each element onto the
%% accumulator. What comes out?
reading_foldl_cons_test() ->
    ?assertEqual([3, 2, 1], lists:foldl(fun(X, Acc) -> [X | Acc] end, [], [1, 2, 3])).

%% Same fun with foldr (right to left).
reading_foldr_cons_test() ->
    ?assertEqual([1, 2, 3], lists:foldr(fun(X, Acc) -> [X | Acc] end, [], [1, 2, 3])).

%% The accumulator can be any term. Here it is a tuple of two counters.
reading_foldl_tuple_acc_test() ->
    Count = fun(X, {Evens, Odds}) when X rem 2 =:= 0 -> {Evens + 1, Odds};
               (_, {Evens, Odds}) -> {Evens, Odds + 1}
            end,
    ?assertEqual({2, 3}, lists:foldl(Count, {0, 0}, [1, 2, 3, 4, 5])).

%% key* functions take the key POSITION. Which tuple comes back from each?
reading_key_position_test() ->
    L = [{a, 1}, {b, 2}, {c, 3}],
    ?assertEqual({b, 2}, lists:keyfind(b, 1, L)),
    ?assertEqual({b, 2}, lists:keyfind(2, 2, L)),
    ?assertEqual(false, lists:keyfind(2, 1, L)).

%% keyreplace replaces the first tuple with that key, or leaves the list
%% unchanged if the key is absent.
reading_keyreplace_test() ->
    L = [{a, 1}, {b, 2}],
    ?assertEqual([{a, 1}, {b, 20}], lists:keyreplace(b, 1, L, {b, 20})),
    ?assertEqual([{a, 1}, {b, 2}], lists:keyreplace(z, 1, L, {z, 0})).

%% lists:nth is 1-indexed. lists:sort uses term order, so mixed types work.
reading_nth_and_sort_test() ->
    ?assertEqual(a, lists:nth(1, [a, b, c])),
    ?assertEqual([1, 2, a, b], lists:sort([b, 2, a, 1])).

%% zip pairs elements; unzip undoes it. Predict both.
reading_zip_test() ->
    ?assertEqual([{1, a}, {2, b}], lists:zip([1, 2], [a, b])),
    ?assertEqual({[1, 2], [a, b]}, lists:unzip([{1, a}, {2, b}])).

%% usort sorts AND removes duplicates. partition splits into two lists.
reading_usort_partition_test() ->
    ?assertEqual([1, 2, 3], lists:usort([3, 1, 3, 2, 1])),
    ?assertEqual({[3, 4], [1, 2]}, lists:partition(fun(X) -> X > 2 end, [1, 2, 3, 4])).
