%% I AM NOT DONE
-module(map_basics_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

new_user_test() ->
    ?assertEqual(#{name => <<"ann">>, age => 31}, map_basics:new_user(<<"ann">>, 31)).

get_age_test() ->
    ?assertEqual(31, map_basics:get_age(#{name => <<"ann">>, age => 31, extra => x})).

birthday_test() ->
    ?assertEqual(#{name => <<"ann">>, age => 32},
                 map_basics:birthday(#{name => <<"ann">>, age => 31})).

rename_test() ->
    ?assertEqual(#{name => <<"bob">>, age => 31},
                 map_basics:rename(#{name => <<"ann">>, age => 31}, <<"bob">>)).

has_email_test() ->
    ?assertEqual(true, map_basics:has_email(#{email => undefined})),
    ?assertEqual(false, map_basics:has_email(#{name => <<"ann">>})).

merge_defaults_test() ->
    ?assertEqual(#{port => 80, host => <<"x">>},
                 map_basics:merge_defaults(#{port => 80}, #{port => 8080, host => <<"x">>})).

to_pairs_test() ->
    ?assertEqual([{a, 1}, {b, 2}, {c, 3}], map_basics:to_pairs(#{c => 3, a => 1, b => 2})).

count_words_test() ->
    ?assertEqual(#{<<"a">> => 2, <<"b">> => 1},
                 map_basics:count_words([<<"a">>, <<"b">>, <<"a">>])),
    ?assertEqual(#{}, map_basics:count_words([])).

invert_test() ->
    ?assertEqual(#{1 => a, 2 => b}, map_basics:invert(#{a => 1, b => 2})).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% => inserts or updates; := only updates. One of these two raises.
%% Predict the class and reason of the error, as {Class, Reason}.
reading_update_syntax_test() ->
    M = maps:from_list([{a, 1}]),
    ?assertEqual(?TODO, M#{b => 2}),
    Caught = try M#{b := 2} catch C:R -> {C, R} end,
    ?assertEqual(?TODO, Caught).

%% A map pattern matches if the listed keys are present; extra keys are fine.
%% Does this match (ok) or fall through (no_match)?
reading_partial_pattern_test() ->
    Result = case #{a => 1, b => 2, c => 3} of
                 #{a := 1, c := C} -> {ok, C};
                 _ -> no_match
             end,
    ?assertEqual(?TODO, Result).

%% The empty map pattern #{} matches ANY map, not just the empty one.
reading_empty_pattern_test() ->
    Result = case #{a => 1} of
                 #{} -> any_map;
                 _ -> something_else
             end,
    ?assertEqual(?TODO, Result).

%% maps:get/2 vs maps:get/3 vs maps:find/2 on a missing key.
reading_lookups_test() ->
    M = maps:from_list([{a, 1}]),
    ?assertEqual(?TODO, maps:get(a, M, 0)),
    ?assertEqual(?TODO, maps:get(z, M, 0)),
    ?assertEqual(?TODO, maps:find(z, M)),
    Caught = try maps:get(z, M) catch error:R -> R end,
    ?assertEqual(?TODO, Caught).

%% maps:merge/2: the second map wins.
reading_merge_test() ->
    ?assertEqual(?TODO, maps:merge(#{a => 1, b => 1}, #{b => 2, c => 2})).

%% Keys are compared with =:=, so 1 and 1.0 are different keys.
reading_key_identity_test() ->
    M = #{1 => int, 1.0 => float},
    ?assertEqual(?TODO, map_size(M)),
    ?assertEqual(?TODO, maps:get(1, M)).

%% Map order is structural, not insertion order. Are these equal?
reading_equality_test() ->
    ?assertEqual(?TODO, #{a => 1, b => 2} =:= #{b => 2, a => 1}).

%% maps:fold passes (Key, Value, Acc). What does this compute?
reading_fold_test() ->
    Sum = maps:fold(fun(_K, V, Acc) -> Acc + V end, 0, #{a => 1, b => 2, c => 3}),
    ?assertEqual(?TODO, Sum).

%% Map comprehension (OTP 26+). Predict the result map.
reading_comprehension_test() ->
    ?assertEqual(?TODO, #{K => V * 10 || K := V <- #{a => 1, b => 2}}).
