%% I AM NOT DONE
-module(case_if_and_scope_tests).

-include_lib("eunit/include/eunit.hrl").

%% `opaque/1` hides a value from the compiler's constant folding so the
%% examples below behave the way they would with real runtime data.
-export([opaque/1]).
opaque(X) -> X.

-define(TODO, '__TODO__').

grade_test() ->
    ?assertEqual(a, case_if_and_scope:grade(95)),
    ?assertEqual(a, case_if_and_scope:grade(90)),
    ?assertEqual(b, case_if_and_scope:grade(85)),
    ?assertEqual(c, case_if_and_scope:grade(70)),
    ?assertEqual(f, case_if_and_scope:grade(69)),
    ?assertEqual(f, case_if_and_scope:grade(0)).

sign_test() ->
    ?assertEqual(negative, case_if_and_scope:sign(-3)),
    ?assertEqual(zero, case_if_and_scope:sign(0)),
    ?assertEqual(positive, case_if_and_scope:sign(2.5)).

label_test() ->
    ?assertEqual("zero", case_if_and_scope:label(0)),
    ?assertEqual("nonzero", case_if_and_scope:label(7)),
    ?assertEqual("nonzero", case_if_and_scope:label(-1)).

describe_list_test() ->
    ?assertEqual(empty, case_if_and_scope:describe_list([])),
    ?assertEqual({single, a}, case_if_and_scope:describe_list([a])),
    ?assertEqual({many, 3}, case_if_and_scope:describe_list([a, b, c])).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% `=` is a match, not an assignment. What happens on the second line?
%% Fill in the exception reason (the thing inside error:...).
rebinding_test() ->
    ?assertError(?TODO, begin X = ?MODULE:opaque(1), X = ?MODULE:opaque(2), X end).

%% ...but matching the SAME value again is fine. What does this return?
same_value_match_test() ->
    ?assertEqual(?TODO, begin X = ?MODULE:opaque(1), X = ?MODULE:opaque(1), X end).

%% `if` with no true branch: what is the exception reason?
if_clause_test() ->
    N = ?MODULE:opaque(5),
    ?assertError(?TODO, if N < 0 -> negative; N == 0 -> zero end).

%% `case` is an expression. What does the whole begin...end evaluate to?
case_is_expression_test() ->
    V = begin
            R = case lists:member(2, [1, 2, 3]) of
                    true -> found;
                    false -> missing
                end,
            {result, R}
        end,
    ?assertEqual(?TODO, V).

%% A guard that raises (hd/1 on a non-list) does not crash: the guard simply
%% fails and the next branch is tried. Which branch runs?
guard_failure_is_false_test() ->
    X = ?MODULE:opaque(not_a_list),
    Out = case X of
              L when hd(L) =:= 1 -> starts_with_one;
              _ -> something_else
          end,
    ?assertEqual(?TODO, Out).

%% Variables bound inside a case branch ARE visible after it, as long as
%% every branch binds them. What is Y?
bound_in_all_branches_test() ->
    case 3 > 2 of
        true -> Y = big;
        false -> Y = small
    end,
    ?assertEqual(?TODO, Y).
