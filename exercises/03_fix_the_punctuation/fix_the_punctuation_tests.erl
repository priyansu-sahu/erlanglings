%% I AM NOT DONE
-module(fix_the_punctuation_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

describe_test() ->
    ?assertEqual("zero", fix_the_punctuation:describe(0)),
    ?assertEqual("negative", fix_the_punctuation:describe(-3)),
    ?assertEqual("positive", fix_the_punctuation:describe(7)).

classify_test() ->
    ?assertEqual(integer, fix_the_punctuation:classify(1)),
    ?assertEqual(atom, fix_the_punctuation:classify(ok)),
    ?assertEqual(list, fix_the_punctuation:classify([1])),
    ?assertEqual(other, fix_the_punctuation:classify({1})).

sum_pairs_test() ->
    ?assertEqual({[3, 7], 10}, fix_the_punctuation:sum_pairs([{1, 2}, {3, 4}])).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Commas sequence expressions; the value of a body is its LAST expression.
%% `_ = Expr` is the idiom for "evaluate this and I know I am ignoring the
%% result" (very common: `_ = gen_server:cast(...)`). It silences the
%% compiler's "term is constructed but never used" warning.
%% What does this begin ... end block evaluate to?
reading_last_expression_test() ->
    Result = begin
                 _ = 1,
                 _ = 2,
                 3
             end,
    ?assertEqual(?TODO, Result).

%% A clause body may have many expressions whose values are discarded or
%% bound and never used. Only the final one is the result. What is Result?
reading_discarded_test() ->
    Result = case ok of
                 ok ->
                     A = 10,
                     B = 20,
                     _Product = A * B,
                     A + B
             end,
    ?assertEqual(?TODO, Result).

%% Clauses are tried in order; `;` separates alternatives. Funs have clauses
%% too. Which clause runs for each call?
reading_clause_order_test() ->
    F = fun(second) -> matched_second;
           (_) -> fell_through
        end,
    ?assertEqual(?TODO, F(second)),
    ?assertEqual(?TODO, F(third)).
