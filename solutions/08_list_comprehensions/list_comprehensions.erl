-module(list_comprehensions).

-export([squares/1, odds/1, pairs/2, ages_of_adults/1, ok_values/1,
         lookup_all/2, bytes_to_hex/1]).

%% A list comprehension builds a list from generators and filters:
%%
%%   [ Expression || Generator, Filter, Generator, ... ]
%%
%%   [X * 2 || X <- [1, 2, 3]]                   map          -> [2, 4, 6]
%%   [X || X <- L, X > 2]                        filter       -> elements > 2
%%   [{X, Y} || X <- [1, 2], Y <- [a, b]]        cartesian    -> 4 pairs
%%   [V || {ok, V} <- Results]                   PATTERN as generator
%%
%% Read `<-` as "drawn from" and `||` as "for each". Filters are any boolean
%% expression (or a guard-like test); elements where a filter is false are
%% skipped.
%%
%% The pattern-generator trick is the one to really notice:
%%
%%   [V || {ok, V} <- Results]
%%
%% Elements that do NOT match the pattern {ok, V} are silently skipped, not
%% an error. This is how a lot of production code filters tagged tuples in
%% one line. It is terse and easy to misread: the pattern is doing both
%% destructuring and filtering.
%%
%% Variables bound inside a comprehension are local to it. A variable from
%% outside used in a pattern (`[X || X <- L]` where X is already bound) is a
%% comparison, which is almost never what the author meant; recent compilers
%% warn about this.
%%
%% Binary comprehensions use << >> and <= instead of [ ] and <-:
%%
%%   << <<(X * 2)>> || <<X>> <= Bin >>           map over bytes of a binary
%%   [X || <<X>> <= Bin]                         bytes of a binary as a list
%%
%% The spacing `<< <<` is needed so the tokenizer does not read `<<<<`.
%%
%% Since OTP 26 there are also map comprehensions:
%%   #{K => V * 2 || K := V <- Map}
%% You will meet those in exercise 11.

%% TODO: squares of the numbers 1..N.
%%   squares(3) -> [1, 4, 9]
-spec squares(non_neg_integer()) -> [pos_integer()].
squares(N) ->
    [X * X || X <- lists:seq(1, N)].

%% TODO: only the odd integers from the list.
-spec odds([integer()]) -> [integer()].
odds(L) ->
    [X || X <- L, X rem 2 =:= 1].

%% TODO: every {A, B} with A from Xs and B from Ys, where A < B.
%%   pairs([1, 2], [1, 2, 3]) -> [{1, 2}, {1, 3}, {2, 3}]
-spec pairs([integer()], [integer()]) -> [{integer(), integer()}].
pairs(Xs, Ys) ->
    [{A, B} || A <- Xs, B <- Ys, A < B].

%% TODO: given [{Name, Age}], the ages of users 18 or older.
-spec ages_of_adults([{binary(), integer()}]) -> [integer()].
ages_of_adults(Users) ->
    [Age || {_Name, Age} <- Users, Age >= 18].

%% TODO: the payloads of all {ok, V} results, skipping errors. One line.
-spec ok_values([{ok, term()} | {error, term()}]) -> [term()].
ok_values(Results) ->
    [V || {ok, V} <- Results].

%% TODO: for each Key in Keys, the value in the proplist Pairs, skipping keys
%% that are absent. Use a comprehension with a filter calling
%% lists:keyfind/3 (or a pattern generator over Pairs).
%%   lookup_all([a, z, b], [{a, 1}, {b, 2}]) -> [1, 2]
-spec lookup_all([term()], [{term(), term()}]) -> [term()].
lookup_all(Keys, Pairs) ->
    [V || K <- Keys, {K2, V} <- Pairs, K =:= K2].

%% TODO: render a binary as lowercase hex, two chars per byte.
%%   bytes_to_hex(<<255, 1, 16>>) -> "ff0110"
%% Use a binary generator `<<B>> <= Bin` and io_lib:format("~2.16.0b", [B])
%% to format one byte; lists:flatten the result. (Or use binary:encode_hex/1
%% and convert; but try the comprehension.)
-spec bytes_to_hex(binary()) -> string().
bytes_to_hex(Bin) ->
    lists:flatten([io_lib:format("~2.16.0b", [B]) || <<B>> <= Bin]).
