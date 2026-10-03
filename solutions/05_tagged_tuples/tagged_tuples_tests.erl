-module(tagged_tuples_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

parse_age_test() ->
    ?assertEqual({ok, 42}, tagged_tuples:parse_age("42")),
    ?assertEqual({ok, 0}, tagged_tuples:parse_age("0")),
    ?assertEqual({error, negative}, tagged_tuples:parse_age("-3")),
    ?assertEqual({error, not_an_integer}, tagged_tuples:parse_age("abc")),
    ?assertEqual({error, not_an_integer}, tagged_tuples:parse_age("12abc")).

unwrap_test() ->
    ?assertEqual(42, tagged_tuples:unwrap({ok, 42})),
    ?assertError(boom, tagged_tuples:unwrap({error, boom})).

unwrap_or_test() ->
    ?assertEqual(42, tagged_tuples:unwrap_or({ok, 42}, 0)),
    ?assertEqual(0, tagged_tuples:unwrap_or({error, nope}, 0)),
    ?assertEqual(0, tagged_tuples:unwrap_or(error, 0)).

lookup_test() ->
    Pairs = [{name, <<"wa">>}, {port, 5222}],
    ?assertEqual({ok, 5222}, tagged_tuples:lookup(port, Pairs)),
    ?assertEqual(error, tagged_tuples:lookup(host, Pairs)).

all_ok_test() ->
    ?assertEqual({ok, [1, 2, 3]}, tagged_tuples:all_ok([{ok, 1}, {ok, 2}, {ok, 3}])),
    ?assertEqual({ok, []}, tagged_tuples:all_ok([])),
    ?assertEqual({error, a}, tagged_tuples:all_ok([{ok, 1}, {error, a}, {error, b}])).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Different library functions signal "not found" differently. Predict each.
reading_not_found_conventions_test() ->
    ?assertEqual(error, maps:find(x, #{})),
    ?assertEqual(false, lists:keyfind(x, 1, [{a, 1}])),
    ?assertEqual(undefined, proplists:get_value(x, [{a, 1}])),
    ?assertEqual(default, maps:get(x, #{}, default)).

%% lists:keyfind returns the WHOLE tuple, not the value.
reading_keyfind_test() ->
    ?assertEqual({b, 2}, lists:keyfind(b, 1, [{a, 1}, {b, 2}, {c, 3}])).

%% Asserting the happy path. What error term does the badmatch carry?
%% (Predict the Reason bound in the catch clause.)
reading_assert_happy_path_test() ->
    Reason = try
                 {ok, _V} = file:read_file("/no/such/file/anywhere"),
                 no_crash
             catch
                 error:R -> R
             end,
    ?assertEqual({badmatch, {error, enoent}}, Reason).

%% The `Pattern = Var` alias: match the shape AND keep the whole term.
%% Here Err is bound to the entire tuple. What is returned?
reading_alias_pattern_test() ->
    Result = case {error, timeout} of
                 {ok, V} -> V;
                 {error, _} = Err -> Err
             end,
    ?assertEqual({error, timeout}, Result).

%% Nested tagged tuples are common: {ok, {Pid, Ref}} vs {ok, Pid, Ref}.
%% These are different shapes. How many elements does each tuple have?
reading_shape_test() ->
    ?assertEqual(2, tuple_size({ok, {pid, ref}})),
    ?assertEqual(3, tuple_size({ok, pid, ref})).

%% element/2 is 1-indexed. What is element(1, ...) of a tagged tuple?
reading_element_test() ->
    ?assertEqual(error, element(1, {error, timeout})),
    ?assertEqual(timeout, element(2, {error, timeout})).
