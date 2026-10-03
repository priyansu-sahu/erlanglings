-module(map_basics).

-export([new_user/2, get_age/1, birthday/1, rename/2, has_email/1,
         merge_defaults/2, to_pairs/1, count_words/1, invert/1]).

%% Maps are Erlang's key-value type (OTP 17+). In modern code they have
%% largely replaced proplists and dict, and they compete with records
%% (exercise 12) for "a struct with named fields".
%%
%% Syntax, which trips everyone up at first:
%%
%%   #{}                        empty map
%%   #{name => <<"ann">>, age => 31}        build: key => value
%%   M#{age => 32}              update-or-insert age (=> works for new keys)
%%   M#{age := 32}              update age, which MUST already exist (else badkey)
%%   #{age := A} = M            match: := in patterns (=> is NOT allowed here)
%%   #{age := A, name := N} = M several keys at once; the map may have more
%%
%% Rule: `=>` puts things in, `:=` requires the key to be there already.
%% In a pattern you can only use `:=`, because a pattern asks "is it there?".
%%
%% Keys can be any term, but in practice they are atoms (config, state) or
%% binaries (JSON-decoded data). A map with atom keys reads like a struct; a
%% map with binary keys is almost always external data.
%%
%% The maps module:
%%   maps:get(K, M)           value or badkey error
%%   maps:get(K, M, Default)  value or Default
%%   maps:find(K, M)          {ok, V} | error
%%   maps:is_key(K, M)        boolean
%%   maps:put(K, V, M)        same as M#{K => V}
%%   maps:update(K, V, M)     same as M#{K := V}
%%   maps:remove(K, M)
%%   maps:merge(M1, M2)       M2's values win on conflicts
%%   maps:keys(M)  maps:values(M)  maps:size(M)  map_size(M) (guard-safe)
%%   maps:to_list(M)  maps:from_list([{K, V}])
%%   maps:map(F, M)  maps:filter(Pred, M)  maps:fold(F, Acc, M)
%%   maps:with(Keys, M)  maps:without(Keys, M)
%%   maps:update_with(K, Fun, M)  maps:update_with(K, Fun, Init, M)
%%
%% Map comprehensions (OTP 26+):
%%   #{K => V * 2 || K := V <- M}        over a map
%%   #{X => true || X <- List}           from a list
%%
%% Map key order: maps with up to 32 keys print and iterate in sorted key
%% order; larger ones are hash-ordered. Never rely on iteration order.
%%
%% Equality is structural: #{a => 1, b => 2} =:= #{b => 2, a => 1}.

%% TODO: build #{name => Name, age => Age}.
-spec new_user(binary(), non_neg_integer()) -> #{name := binary(), age := non_neg_integer()}.
new_user(Name, Age) ->
    #{name => Name, age => Age}.

%% TODO: the age, via a pattern match in the function head.
-spec get_age(#{age := non_neg_integer(), _ => _}) -> non_neg_integer().
get_age(#{age := Age}) ->
    Age.

%% TODO: increment age by one. Use the := update syntax.
-spec birthday(map()) -> map().
birthday(#{age := Age} = User) ->
    User#{age := Age + 1}.

%% TODO: set name to NewName (the key always exists).
-spec rename(map(), binary()) -> map().
rename(User, NewName) ->
    User#{name := NewName}.

%% TODO: true if the map has an `email` key (regardless of value).
-spec has_email(map()) -> boolean().
has_email(User) ->
    maps:is_key(email, User).

%% TODO: fill in missing keys from Defaults; values already in Config win.
%%   merge_defaults(#{port => 80}, #{port => 8080, host => <<"x">>})
%%     -> #{port => 80, host => <<"x">>}
%% maps:merge/2 does this; mind the argument order.
-spec merge_defaults(map(), map()) -> map().
merge_defaults(Config, Defaults) ->
    maps:merge(Defaults, Config).

%% TODO: the map as a list of {Key, Value} tuples, sorted by key.
-spec to_pairs(map()) -> [{term(), term()}].
to_pairs(M) ->
    lists:sort(maps:to_list(M)).

%% TODO: count how often each word occurs in a list of binaries.
%%   count_words([<<"a">>, <<"b">>, <<"a">>]) -> #{<<"a">> => 2, <<"b">> => 1}
%% Use lists:foldl with maps:update_with/4 (the 4-arity version takes an
%% initial value for absent keys), or maps:get/3 and =>.
-spec count_words([binary()]) -> #{binary() => pos_integer()}.
count_words(Words) ->
    lists:foldl(fun(Word, Acc) ->
                        maps:update_with(Word, fun(N) -> N + 1 end, 1, Acc)
                end, #{}, Words).

%% TODO: swap keys and values. Assume values are unique.
%%   invert(#{a => 1, b => 2}) -> #{1 => a, 2 => b}
%% Try a map comprehension: #{V => K || K := V <- M}.
-spec invert(map()) -> map().
invert(M) ->
    #{V => K || K := V <- M}.
