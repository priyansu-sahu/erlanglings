-module(list_comprehensions_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

squares_test() ->
    ?assertEqual([1, 4, 9], list_comprehensions:squares(3)),
    ?assertEqual([], list_comprehensions:squares(0)).

odds_test() ->
    ?assertEqual([1, 3, 5], list_comprehensions:odds([1, 2, 3, 4, 5])).

pairs_test() ->
    ?assertEqual([{1, 2}, {1, 3}, {2, 3}], list_comprehensions:pairs([1, 2], [1, 2, 3])).

ages_of_adults_test() ->
    Users = [{<<"ann">>, 31}, {<<"kid">>, 9}, {<<"bob">>, 18}],
    ?assertEqual([31, 18], list_comprehensions:ages_of_adults(Users)).

ok_values_test() ->
    ?assertEqual([1, 3], list_comprehensions:ok_values([{ok, 1}, {error, x}, {ok, 3}])).

lookup_all_test() ->
    ?assertEqual([1, 2], list_comprehensions:lookup_all([a, z, b], [{a, 1}, {b, 2}])).

bytes_to_hex_test() ->
    ?assertEqual("ff0110", list_comprehensions:bytes_to_hex(<<255, 1, 16>>)),
    ?assertEqual("", list_comprehensions:bytes_to_hex(<<>>)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Two generators: the rightmost varies fastest. Predict the order.
reading_two_generators_test() ->
    ?assertEqual([{1, a}, {1, b}, {2, a}, {2, b}], [{X, Y} || X <- [1, 2], Y <- [a, b]]).

%% A pattern in the generator silently drops non-matching elements.
reading_pattern_generator_test() ->
    L = [{ok, 1}, {error, bad}, {ok, 2}, nonsense],
    ?assertEqual([1, 2], [V || {ok, V} <- L]).

%% Filters can be guards or any boolean expression; several filters are ANDed.
reading_filters_test() ->
    ?assertEqual([6, 8, 10], [X || X <- lists:seq(1, 10), X rem 2 =:= 0, X > 4]).

%% A generator can draw from the result of a previous one.
reading_dependent_generators_test() ->
    ?assertEqual([{1, 1}, {2, 1}, {2, 2}, {3, 1}, {3, 2}, {3, 3}], [{X, Y} || X <- [1, 2, 3], Y <- lists:seq(1, X)]).

%% The expression may build anything, including nested lists and binaries.
reading_build_binaries_test() ->
    ?assertEqual([<<"A">>, <<"B">>], [<<N>> || N <- [65, 66]]).

%% Binary comprehension: `<= ` draws from a binary. What list comes out?
reading_binary_generator_test() ->
    ?assertEqual([1, 2, 3], [B || <<B>> <= <<1, 2, 3>>]).

%% Building a binary from a binary. Predict the result binary.
reading_binary_to_binary_test() ->
    ?assertEqual(<<2, 3, 4>>, << <<(B + 1)>> || <<B>> <= <<1, 2, 3>> >>).

%% Filters are ordinary boolean expressions and may call functions (unlike
%% guards). How many words survive this one?
reading_function_filter_test() ->
    Words = ["erlang", "otp", "beam", "gen_server"],
    ?assertEqual(3, length([W || W <- Words, length(W) > 3])).
