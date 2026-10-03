-module(lists_module).

-export([doubles/1, evens/1, total/1, names/1, oldest/1, by_name/2,
         word_lengths/1, top_n/2]).

%% Hand-written recursion is for when nothing in `lists` fits. In practice,
%% most list processing in production code goes through a dozen functions
%% from the lists module. Learn these by sight:
%%
%%   lists:map(F, L)            apply F to each element
%%   lists:filter(Pred, L)      keep elements where Pred(X) is true
%%   lists:foldl(F, Acc0, L)    reduce left-to-right: F(Elem, AccIn) -> AccOut
%%   lists:foldr(F, Acc0, L)    same, right-to-left
%%   lists:foreach(F, L)        for side effects; returns ok
%%   lists:sum(L)  lists:max(L)  lists:min(L)  length(L)
%%   lists:reverse(L)  lists:sort(L)  lists:sort(F, L)  lists:usort(L)
%%   lists:member(X, L)         true | false
%%   lists:nth(N, L)            1-indexed!
%%   lists:seq(From, To)        [From, ..., To]
%%   lists:zip(L1, L2)          [{A1, B1}, {A2, B2}, ...]
%%   lists:append(L1, L2)       same as L1 ++ L2
%%   lists:flatten(L)
%%   lists:keyfind(Key, N, TupleList)    tuple whose Nth element is Key | false
%%   lists:keysort(N, TupleList)         sort tuples by Nth element
%%   lists:keydelete/3  keystore/4  keyreplace/4  keymember/3
%%   lists:partition(Pred, L)   {Matching, NotMatching}
%%   lists:split(N, L)          {FirstN, Rest}
%%   lists:sublist(L, N)        first N elements
%%   lists:any(Pred, L)  lists:all(Pred, L)
%%   lists:foldl + lists:reverse  is how most "build a new list" loops look
%%
%% The key* functions operate on lists of tuples and take the POSITION of the
%% key (1-indexed). lists:keyfind(Name, 1, Users) means "find the tuple whose
%% first element is Name". These are extremely common in older code and in
%% anything built around proplists ([{Key, Value}]).
%%
%% Funs: `fun(X) -> X * 2 end` is an anonymous function. `fun lists:sum/1` or
%% `fun local_helper/1` refers to an existing function by name/arity. You
%% will see both passed as the F argument. Exercise 13 covers funs in depth.
%%
%% Argument order to remember: the fun comes FIRST (lists:map(F, L)),
%% and in foldl the fun receives (Element, Accumulator), in that order.

%% TODO: double every element. Use lists:map.
-spec doubles([number()]) -> [number()].
doubles(L) ->
    lists:map(fun(X) -> X * 2 end, L).

%% TODO: keep only even integers. Use lists:filter.
-spec evens([integer()]) -> [integer()].
evens(L) ->
    lists:filter(fun(X) -> X rem 2 =:= 0 end, L).

%% TODO: sum of a list using lists:foldl (not lists:sum).
-spec total([number()]) -> number().
total(L) ->
    lists:foldl(fun(X, Acc) -> Acc + X end, 0, L).

%% The remaining functions work on "user" tuples: {Name, Age}.
%% e.g. [{<<"ann">>, 31}, {<<"bob">>, 25}]

%% TODO: the list of names, in the same order.
-spec names([{binary(), integer()}]) -> [binary()].
names(Users) ->
    lists:map(fun({Name, _Age}) -> Name end, Users).

%% TODO: the name of the oldest user. Assume the list is non-empty.
%% Hint: lists:keysort/2 or lists:max/1 over {Age, Name} tuples, or a foldl.
-spec oldest([{binary(), integer()}]) -> binary().
oldest([First | Rest]) ->
    {Name, _Age} =
        lists:foldl(fun({_, A} = U, {_, BestA}) when A > BestA -> U;
                       (_, Best) -> Best
                    end, First, Rest),
    Name.

%% TODO: find the user tuple with the given name using lists:keyfind.
%% Return {ok, Age} or error.
-spec by_name(binary(), [{binary(), integer()}]) -> {ok, integer()} | error.
by_name(Name, Users) ->
    case lists:keyfind(Name, 1, Users) of
        {Name, Age} -> {ok, Age};
        false -> error
    end.

%% TODO: given a list of strings, return [{String, Length}] pairs.
%% Use lists:zip with lists:map, or a single lists:map.
-spec word_lengths([string()]) -> [{string(), non_neg_integer()}].
word_lengths(Words) ->
    lists:zip(Words, lists:map(fun length/1, Words)).

%% TODO: the N largest numbers, largest first.
%%   top_n(2, [5, 1, 9, 3]) -> [9, 5]
%% Hint: lists:sort/1 is ascending; lists:reverse then lists:sublist, or
%% lists:sort/2 with a comparison fun `fun(A, B) -> A >= B end`.
-spec top_n(non_neg_integer(), [number()]) -> [number()].
top_n(N, L) ->
    lists:sublist(lists:sort(fun(A, B) -> A >= B end, L), N).
