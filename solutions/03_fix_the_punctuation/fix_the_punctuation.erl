-module(fix_the_punctuation).

-export([describe/1, classify/1, sum_pairs/1]).

%% Erlang punctuation trips up every newcomer, and reading it fluently is
%% mostly a matter of knowing three separators:
%%
%%   ,  (comma)      separates expressions inside a clause body,
%%                   and elements inside lists/tuples/argument lists.
%%                   Read it as "and then".
%%
%%   ;  (semicolon)  separates CLAUSES of the same function, case, if,
%%                   receive, try or fun. Read it as "or, alternatively".
%%
%%   .  (full stop)  ends a function definition or an attribute.
%%                   Read it as "end of this top-level thing".
%%
%% A mental model: a function is a list of clauses joined by `;` and
%% terminated by `.`; each clause body is a list of expressions joined by
%% `,`. The last clause of a case/if/receive has no separator after it
%% because `end` closes the construct.
%%
%%   f(a) -> one, two;          <- clause 1 body has two expressions
%%   f(b) -> three.             <- clause 2, and the function ends
%%
%%   case X of
%%       1 -> a;                <- alternative 1
%%       2 -> b                 <- last alternative: NO separator
%%   end.
%%
%% The compiler errors you get when this goes wrong are famous for pointing
%% at the line AFTER the mistake. "syntax error before: f" on line 40 usually
%% means line 39 ended with the wrong separator. Read upward.
%%
%% The code below is logically correct but every function has at least one
%% punctuation mistake. Read the compiler errors, fix the separators, and do
%% not change anything else.

%% TODO: fix the punctuation
describe(0) ->
    "zero";
describe(N) when N < 0 ->
    "negative";
describe(_N) ->
    "positive".

%% TODO: fix the punctuation
classify(X) ->
    case X of
        X when is_integer(X) -> integer;
        X when is_atom(X) -> atom;
        X when is_list(X) -> list;
        _ -> other
    end.

%% TODO: fix the punctuation
sum_pairs(Pairs) ->
    Sums = [A + B || {A, B} <- Pairs],
    Total = lists:sum(Sums),
    {Sums, Total}.
