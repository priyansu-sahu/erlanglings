%% I AM NOT DONE
-module(pattern_matching_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

match_tuple_test() ->
    ?assertEqual(3, pattern_matching:match_tuple({1, 2})),
    ?assertEqual(10, pattern_matching:match_tuple({7, 3})).

match_list_test() ->
    ?assertEqual(1, pattern_matching:match_list([1, 2, 3])),
    ?assertEqual(only, pattern_matching:match_list([only])).

match_map_test() ->
    ?assertEqual(42, pattern_matching:match_map(#{key => 42})),
    ?assertEqual(hi, pattern_matching:match_map(#{other => 1, key => hi})).

swap_test() ->
    ?assertEqual({b, a}, pattern_matching:swap({a, b})).

second_test() ->
    ?assertEqual(2, pattern_matching:second([1, 2, 3])),
    ?assertEqual(y, pattern_matching:second([x, y])).

tagged_test() ->
    ?assertEqual(42, pattern_matching:tagged({ok, 42})),
    ?assertEqual(failed, pattern_matching:tagged({error, timeout})).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% [H | T] splits a list into first element and the rest.
reading_cons_test() ->
    [H | T] = [1, 2, 3],
    ?assertEqual(?TODO, H),
    ?assertEqual(?TODO, T).

%% The tail of a one-element list is the empty list.
reading_single_tail_test() ->
    [_ | T] = [only],
    ?assertEqual(?TODO, T).

%% You can take several elements at once.
reading_two_heads_test() ->
    [A, B | Rest] = [10, 20, 30, 40],
    ?assertEqual(?TODO, A + B),
    ?assertEqual(?TODO, Rest).

%% Nested patterns work to any depth. What is Y?
reading_nested_test() ->
    {ok, {_, Y}, _} = {ok, {1, 2}, 3},
    ?assertEqual(?TODO, Y).

%% A repeated variable means "must be the same". Is this a match or a crash?
%% Predict the atom returned by the case expression.
reading_repeated_var_test() ->
    Result = case {1, 1} of
                 {X, X} -> same;
                 {_, _} -> different
             end,
    ?assertEqual(?TODO, Result).

%% Binding a variable, then matching it again against a different value.
%% try ... catch turns a crash into a value (exercise 14 covers it fully).
%% Does `X = 2` succeed (so Result is the atom ok) or raise badmatch (so
%% Result is {caught, ...})? Predict the whole term.
reading_rebind_test() ->
    [X] = lists:seq(1, 1),
    Result = try
                 X = 2,
                 ok
             catch
                 error:Reason -> {caught, Reason}
             end,
    ?assertEqual(?TODO, Result).

%% Strings are lists, so list patterns work on them. "abc" is [97, 98, 99].
reading_string_pattern_test() ->
    [First | _] = "abc",
    ?assertEqual(?TODO, First).

%% The string prefix pattern: "GET " ++ Rest is sugar for [$G, $E, $T, $  | Rest].
reading_prefix_test() ->
    "GET " ++ Path = "GET /index.html",
    ?assertEqual(?TODO, Path).
