%% I AM NOT DONE
-module(basic_types_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

get_integer_test() ->
    ?assertEqual(42, basic_types:get_integer()).

get_hex_test() ->
    ?assertEqual(255, basic_types:get_hex()).

get_float_test() ->
    ?assertEqual(3.5, basic_types:get_float()).

get_atom_test() ->
    ?assertEqual(erlang, basic_types:get_atom()).

get_boolean_test() ->
    ?assertEqual(true, basic_types:get_boolean()).

get_string_test() ->
    ?assertEqual("Hello, Erlang!", basic_types:get_string()).

get_char_test() ->
    ?assertEqual(97, basic_types:get_char()).

get_binary_test() ->
    ?assertEqual(<<"Hello, Erlang!">>, basic_types:get_binary()).

get_list_test() ->
    ?assertEqual([1, 2, 3], basic_types:get_list()).

get_tuple_test() ->
    ?assertEqual({ok, 42}, basic_types:get_tuple()).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% These assertions call built-in functions and ask you to predict what they
%% return. Work them out by reading, then run to check yourself. When you get
%% one wrong, EUnit prints the expected and actual values side by side.

%% Strings are lists of character codes.
reading_string_is_list_test() ->
    ?assertEqual(?TODO, "abc" =:= [97, 98, 99]).

%% is_list/1, is_binary/1 etc. are type tests. A string literal is a list.
reading_string_type_test() ->
    ?assertEqual(?TODO, is_binary("abc")).

%% 16#FF is 255 in hex. What is 2#1010?
reading_base_literal_test() ->
    ?assertEqual(?TODO, 2#1010).

%% Integer division is `div`, remainder is `rem`. `/` always gives a float.
reading_division_test() ->
    ?assertEqual(?TODO, 7 div 2),
    ?assertEqual(?TODO, 7 rem 2),
    ?assertEqual(?TODO, 6 / 2).

%% =:= is exact equality; == treats 1 and 1.0 as equal.
reading_equality_test() ->
    ?assertEqual(?TODO, 1 == 1.0),
    ?assertEqual(?TODO, 1 =:= 1.0).

%% Atoms compare by name; two atoms with the same name are the same atom.
reading_atom_quote_test() ->
    ?assertEqual(?TODO, 'ok' =:= ok).

%% tuple_size/1 and length/1 do what they say. Note the nested tuple counts
%% as one element.
reading_sizes_test() ->
    ?assertEqual(?TODO, tuple_size({ok, {1, 2}, 3})),
    ?assertEqual(?TODO, length([a, [b, c], d])).
