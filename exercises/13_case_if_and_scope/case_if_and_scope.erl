%% I AM NOT DONE
-module(case_if_and_scope).

-export([grade/1, sign/1, label/1, describe_list/1]).

%% Three things to internalize about Erlang control flow:
%%
%% 1. `case` and `if` are EXPRESSIONS -- they return the value of the branch
%%    that ran. Idiomatic code binds the result:
%%
%%        Label = case X of 0 -> zero; _ -> nonzero end,
%%
%%    rather than assigning inside each branch.
%%
%% 2. Variables are single-assignment. `X = 1, X = 2` is not a reassignment,
%%    it is a failed match (`badmatch`). A variable bound in only SOME branches
%%    of a case is "unsafe" to use after the case -- the compiler refuses.
%%
%% 3. `if` has no `else`. Each branch is a GUARD (so no user functions, only
%%    comparisons and BIFs like is_list/1), and if no guard is true you get an
%%    `if_clause` runtime error. That is why you see `true -> ...` as the last
%%    branch: it is the else. Most Erlang programmers prefer `case` or
%%    multiple function clauses over `if`.

%% Convert a 0..100 score to a letter grade using ONE `case` expression with
%% guards: >= 90 -> a, >= 80 -> b, >= 70 -> c, otherwise f.
%%
%%   case Score of
%%       S when S >= 90 -> a;
%%       ...
%%   end
-spec grade(0..100) -> a | b | c | f.
grade(Score) ->
    undefined.

%% Return negative | zero | positive using an `if` expression.
-spec sign(number()) -> negative | zero | positive.
sign(N) ->
    undefined.

%% This function is supposed to return "zero" for 0 and "nonzero" for anything
%% else. As written it does not compile. Read the compiler's complaint, then
%% rewrite it so the case EXPRESSION produces the value.
-spec label(integer()) -> string().
label(N) ->
    case N of
        0 -> Label = "zero";
        _ -> ok
    end,
    Label.

%% Describe a list: empty | {single, X} | {many, Length}.
%% Hint: `_Rest` -- a variable starting with underscore can be bound without
%% an "unused variable" warning. Plain `_` matches anything and binds nothing.
-spec describe_list(list()) -> empty | {single, term()} | {many, pos_integer()}.
describe_list(List) ->
    undefined.
