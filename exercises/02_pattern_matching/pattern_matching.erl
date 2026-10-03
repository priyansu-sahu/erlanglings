%% I AM NOT DONE
-module(pattern_matching).

-export([match_tuple/1, match_list/1, match_map/1, swap/1, second/1, tagged/1]).

%% `=` is NOT assignment. It is the match operator.
%%
%%   Pattern = Expression
%%
%% evaluates the right-hand side, then tries to make the left-hand side
%% "look like" it. Unbound variables in the pattern get bound to whatever
%% sits in the same position. Literals in the pattern must be equal. If the
%% shapes cannot be reconciled you get a badmatch error.
%%
%%   {ok, Value} = {ok, 42}        binds Value to 42
%%   {ok, Value} = {error, nope}   crashes: {badmatch, {error, nope}}
%%   [Head | Tail] = [1, 2, 3]     Head = 1, Tail = [2, 3]
%%   #{key := V} = #{key => 42}    V = 42   (maps use := in patterns)
%%
%% The same thing happens in function heads: the arguments are matched
%% against the clause's patterns. This is why so much Erlang code has almost
%% no explicit field access; the shape is pulled apart right in the head.
%%
%% Variables are single-assignment. Once X is bound, a later `X = 5` is a
%% comparison that succeeds only if X is already 5. Reading tip: when you see
%% the same variable twice in a pattern, e.g. {K, K}, it means "both positions
%% must hold the same value".
%%
%% `_` matches anything and binds nothing. `_Name` also matches anything; the
%% name is documentation for the reader.

%% TODO: return the sum of the two elements of a 2-tuple.
%% Match the tuple apart in the function head, not in the body.
match_tuple(T) ->
    undefined.

%% TODO: return the first element of a non-empty list.
match_list(L) ->
    undefined.

%% TODO: return the value stored under the atom key `key` in the map.
match_map(M) ->
    undefined.

%% TODO: swap the two elements of a 2-tuple: swap({a, b}) -> {b, a}.
swap(T) ->
    undefined.

%% TODO: return the second element of a list with at least two elements.
second(L) ->
    undefined.

%% TODO: given {ok, Value} return Value; given {error, Reason} return the
%% atom `failed`. Use two clauses, one per shape.
tagged(T) ->
    undefined.
