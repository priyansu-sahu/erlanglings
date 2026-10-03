-module(type_specs_tests).

-include_lib("eunit/include/eunit.hrl").
-include("presence.hrl").

%% `opaque/1` hides a value from the compiler's constant folding.
-export([opaque/1]).
opaque(X) -> X.

-define(P(Id, Status), #presence{user_id = Id, status = Status, since = 1700000000}).

sample() ->
    [?P(1, online), ?P(2, offline), ?P(3, {away, <<"lunch">>}), ?P(4, online)].

describe_test() ->
    ?assertEqual(<<"online">>, type_specs:describe(online)),
    ?assertEqual(<<"offline">>, type_specs:describe(offline)),
    ?assertEqual(<<"away: lunch">>, type_specs:describe({away, <<"lunch">>})).

find_test() ->
    ?assertEqual({ok, ?P(2, offline)}, type_specs:find(2, sample())),
    ?assertEqual({error, not_found}, type_specs:find(99, sample())),
    ?assertEqual({error, not_found}, type_specs:find(1, [])).

online_ids_test() ->
    ?assertEqual([1, 4], type_specs:online_ids(sample())),
    ?assertEqual([], type_specs:online_ids([])).

parse_status_test() ->
    ?assertEqual({ok, online}, type_specs:parse_status(<<"online">>)),
    ?assertEqual({ok, offline}, type_specs:parse_status(<<"offline">>)),
    ?assertEqual({ok, {away, <<"in a meeting">>}},
                 type_specs:parse_status(<<"away:in a meeting">>)),
    ?assertEqual({error, {unknown_status, <<"busy">>}},
                 type_specs:parse_status(<<"busy">>)).

summarize_test() ->
    ?assertEqual(#{total => 4, online => 2, away => 1}, type_specs:summarize(sample())).

pick_test() ->
    Opts = [{timeout, 500}, {name, <<"x">>}],
    ?assertEqual(500, type_specs:pick(timeout, Opts)),
    ?assertEqual(<<"x">>, type_specs:pick(name, Opts)).

ensure_binary_test() ->
    ?assertEqual(<<"abc">>, type_specs:ensure_binary(<<"abc">>)),
    ?assertEqual(<<"abc">>, type_specs:ensure_binary("abc")),
    ?assertEqual(<<"abc">>, type_specs:ensure_binary(["a", <<"b">>, [$c]])),
    ?assertEqual(<<"ok">>, type_specs:ensure_binary(ok)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% The spec for pick/2 says the return is `term() | undefined`. Read the spec
%% (and the hint that proplists:get_value/3 is involved): what comes back for
%% a key that is not in the list?
pick_missing_test() ->
    ?assertEqual(undefined, type_specs:pick(missing, [{a, 1}])).

%% The summarize/1 spec uses `:=` for every key, so every key is mandatory
%% even when there is nothing to count. What is summarize([])?
summarize_empty_test() ->
    ?assertEqual(#{total => 0, online => 0, away => 0}, type_specs:summarize([])).

%% Specs are NOT checked at runtime. describe/1 is spec'd to take status(),
%% but nothing stops a caller passing 42. What does the runtime do? Fill in
%% the error reason.
spec_not_enforced_test() ->
    ?assertError(function_clause, type_specs:describe(42)).

%% `string()` in a spec means a list of characters, never a binary.
%% is_list("abc") and is_binary("abc") are...
string_type_test() ->
    ?assertEqual(true, is_list(opaque("abc"))),
    ?assertEqual(false, is_binary(opaque("abc"))).
