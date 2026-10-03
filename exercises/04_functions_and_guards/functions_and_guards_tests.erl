%% I AM NOT DONE
-module(functions_and_guards_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

sign_test() ->
    ?assertEqual(negative, functions_and_guards:sign(-5)),
    ?assertEqual(zero, functions_and_guards:sign(0)),
    ?assertEqual(positive, functions_and_guards:sign(3.5)).

grade_test() ->
    ?assertEqual(a, functions_and_guards:grade(95)),
    ?assertEqual(a, functions_and_guards:grade(90)),
    ?assertEqual(b, functions_and_guards:grade(85)),
    ?assertEqual(c, functions_and_guards:grade(70)),
    ?assertEqual(f, functions_and_guards:grade(69)).

describe_test() ->
    ?assertEqual(integer, functions_and_guards:describe(1)),
    ?assertEqual(float, functions_and_guards:describe(1.0)),
    ?assertEqual(atom, functions_and_guards:describe(hello)),
    ?assertEqual(binary, functions_and_guards:describe(<<"hi">>)),
    ?assertEqual(list, functions_and_guards:describe("hi")),
    ?assertEqual(other, functions_and_guards:describe({1, 2})).

clamp_test() ->
    ?assertEqual(5, functions_and_guards:clamp(5, 0, 10)),
    ?assertEqual(0, functions_and_guards:clamp(-3, 0, 10)),
    ?assertEqual(10, functions_and_guards:clamp(42, 0, 10)).

safe_div_test() ->
    ?assertEqual({ok, 3}, functions_and_guards:safe_div(7, 2)),
    ?assertEqual({error, division_by_zero}, functions_and_guards:safe_div(7, 0)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Clauses are tried in order. The first matching clause wins even if a later
%% one is "more specific". Which atom comes back for 10?
reading_first_match_wins_test() ->
    F = fun(N) when N > 5 -> big;
           (N) when N > 8 -> bigger;
           (_) -> small
        end,
    ?assertEqual(?TODO, F(10)).

%% In a guard, `,` is AND and `;` is OR. Which clause runs for 4? For 15?
reading_and_or_test() ->
    F = fun(N) when N rem 2 =:= 0, N > 10 -> big_even;
           (N) when N rem 2 =:= 0; N > 10 -> even_or_big;
           (_) -> neither
        end,
    ?assertEqual(?TODO, F(4)),
    ?assertEqual(?TODO, F(15)),
    ?assertEqual(?TODO, F(7)).

%% A guard that would raise an exception counts as false; it does not crash.
%% length(an_atom) would be a badarg at runtime, but in a guard it just fails.
reading_failing_guard_test() ->
    F = fun(L) when length(L) > 1 -> long;
           (_) -> short_or_not_a_list
        end,
    ?assertEqual(?TODO, F([1, 2, 3])),
    ?assertEqual(?TODO, F(not_a_list)).

%% No clause matches: the call raises error:function_clause.
%% What is the atom bound to Class?
reading_function_clause_test() ->
    F = fun(1) -> one end,
    Class = try F(2) catch C:_ -> C end,
    ?assertEqual(?TODO, Class).

%% `andalso` / `orelse` short-circuit and can be used both in guards and in
%% ordinary code. `and` / `or` evaluate both sides. What is Result?
reading_andalso_test() ->
    L = [],
    Result = (L =/= []) andalso (hd(L) =:= 1),
    ?assertEqual(?TODO, Result).

%% Comparison operators: =< is "less or equal". What is the list?
reading_operators_test() ->
    ?assertEqual(?TODO, [1 =< 1, 2 =/= 2.0, 2 /= 2.0, 1 >= 2]).
