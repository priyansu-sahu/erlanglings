%% I AM NOT DONE
-module(recursion).

-export([sum/1, len/1, reverse/1, count/2, take/2, range/2, flatten/1]).

%% Erlang has no loops. Every `for`/`while` you would write elsewhere is a
%% recursive function here, and the standard library (lists:map, foldl, ...)
%% is itself written this way. You must be able to read recursion without
%% thinking, because it is everywhere.
%%
%% Two shapes cover nearly all the recursion you will meet:
%%
%% 1. Body recursion: do the work AFTER the recursive call returns.
%%
%%      sum([]) -> 0;
%%      sum([H | T]) -> H + sum(T).
%%
%%    Easy to read; builds a stack as deep as the list. Fine for small or
%%    bounded input, and the compiler handles it well for list building.
%%
%% 2. Tail recursion with an accumulator: do the work BEFORE the call, pass
%%    the partial result along, return the accumulator at the end. The
%%    recursive call is the LAST thing the clause does, so no stack grows.
%%
%%      sum(L) -> sum(L, 0).                 %% public entry, arity 1
%%      sum([], Acc) -> Acc;                 %% base case
%%      sum([H | T], Acc) -> sum(T, Acc + H). %% step
%%
%%    The private helper usually has the same name and one extra argument.
%%    When reading a module, `foo/1` calling `foo/2` with an extra `[]` or `0`
%%    is this pattern. Servers' main loops (loop(State) -> ... loop(NewState))
%%    are tail recursion that never terminates.
%%
%% Accumulating a list with [X | Acc] builds it BACKWARDS, so these helpers
%% end with lists:reverse(Acc). That final reverse is idiomatic; do not be
%% alarmed by it.
%%
%% Reading tip: find the base case(s) first (clauses matching [] or 0).
%% They tell you what the function ultimately produces.

%% TODO: sum of a list of numbers. Use a tail-recursive helper sum/2.
-spec sum([number()]) -> number().
sum(List) ->
    undefined.

%% TODO: length of a list, without calling length/1.
-spec len(list()) -> non_neg_integer().
len(List) ->
    undefined.

%% TODO: reverse a list, without lists:reverse. Accumulate with [H | Acc].
-spec reverse(list()) -> list().
reverse(List) ->
    undefined.

%% TODO: how many times does Elem occur in List?
-spec count(term(), list()) -> non_neg_integer().
count(Elem, List) ->
    undefined.

%% TODO: the first N elements of a list (or the whole list if shorter).
%%   take(2, [a, b, c]) -> [a, b]
%%   take(5, [a])       -> [a]
-spec take(non_neg_integer(), list()) -> list().
take(N, List) ->
    undefined.

%% TODO: the integers From..To inclusive; [] if From > To.
%%   range(1, 4) -> [1, 2, 3, 4]
-spec range(integer(), integer()) -> [integer()].
range(From, To) ->
    undefined.

%% TODO: flatten a nested list one level at a time, without lists:flatten.
%%   flatten([1, [2, [3, 4]], 5]) -> [1, 2, 3, 4, 5]
%% Hint: three cases for the head: it is a list, or it is not; and the
%% empty-list base case. `++` appends two lists.
-spec flatten(list()) -> list().
flatten(List) ->
    undefined.
