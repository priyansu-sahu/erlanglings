-module(case_if_and_scope).

-export([grade/1, sign/1, label/1, describe_list/1]).

-spec grade(0..100) -> a | b | c | f.
grade(Score) ->
    case Score of
        S when S >= 90 -> a;
        S when S >= 80 -> b;
        S when S >= 70 -> c;
        _ -> f
    end.

-spec sign(number()) -> negative | zero | positive.
sign(N) ->
    if
        N < 0 -> negative;
        N == 0 -> zero;
        true -> positive
    end.

-spec label(integer()) -> string().
label(N) ->
    case N of
        0 -> "zero";
        _ -> "nonzero"
    end.

-spec describe_list(list()) -> empty | {single, term()} | {many, pos_integer()}.
describe_list([]) -> empty;
describe_list([X]) -> {single, X};
describe_list(List) -> {many, length(List)}.
