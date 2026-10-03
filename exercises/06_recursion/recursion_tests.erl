%% I AM NOT DONE
-module(recursion_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

sum_test() ->
    ?assertEqual(0, recursion:sum([])),
    ?assertEqual(10, recursion:sum([1, 2, 3, 4])).

len_test() ->
    ?assertEqual(0, recursion:len([])),
    ?assertEqual(3, recursion:len([a, b, c])).

reverse_test() ->
    ?assertEqual([], recursion:reverse([])),
    ?assertEqual([3, 2, 1], recursion:reverse([1, 2, 3])).

count_test() ->
    ?assertEqual(0, recursion:count(x, [a, b])),
    ?assertEqual(2, recursion:count(a, [a, b, a])).

take_test() ->
    ?assertEqual([a, b], recursion:take(2, [a, b, c])),
    ?assertEqual([a], recursion:take(5, [a])),
    ?assertEqual([], recursion:take(0, [a, b])).

range_test() ->
    ?assertEqual([1, 2, 3, 4], recursion:range(1, 4)),
    ?assertEqual([3], recursion:range(3, 3)),
    ?assertEqual([], recursion:range(5, 1)).

flatten_test() ->
    ?assertEqual([1, 2, 3, 4, 5], recursion:flatten([1, [2, [3, 4]], 5])),
    ?assertEqual([], recursion:flatten([[], [[]]])).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Trace this by hand. Each step adds the head to Acc, so the list comes out
%% in what order?
reading_accumulator_order_test() ->
    F = fun Walk([], Acc) -> Acc;
            Walk([H | T], Acc) -> Walk(T, [H | Acc])
        end,
    ?assertEqual(?TODO, F([1, 2, 3], [])).

%% Body recursion: the work (`* 2`) happens after the recursive call returns.
%% What does Double([1, 2, 3]) produce, and in what order?
reading_body_recursion_test() ->
    Double = fun D([]) -> [];
                 D([H | T]) -> [H * 2 | D(T)]
             end,
    ?assertEqual(?TODO, Double([1, 2, 3])).

%% A classic shape: recurse on two elements at a time. What are the results?
%% Note the clauses: an odd element at the end has nowhere to go, so the
%% author handles [X] explicitly.
reading_pairs_test() ->
    Pairs = fun P([A, B | Rest]) -> [{A, B} | P(Rest)];
                P([X]) -> [{X, none}];
                P([]) -> []
            end,
    ?assertEqual(?TODO, Pairs([1, 2, 3, 4])),
    ?assertEqual(?TODO, Pairs([1, 2, 3])).

%% Counting down, building up. What list does this build?
reading_countdown_test() ->
    Build = fun B(0, Acc) -> Acc;
                B(N, Acc) -> B(N - 1, [N | Acc])
            end,
    ?assertEqual(?TODO, Build(4, [])).

%% A missing base case. The call never matches [] and reaches the end of the
%% clauses. Which error class/reason do you get? Predict the whole tuple.
reading_missing_base_case_test() ->
    Bad = fun L([H | T]) -> H + L(T) end,
    Caught = try Bad([1, 2]) catch Class:Reason -> {Class, Reason} end,
    ?assertEqual(?TODO, Caught).
