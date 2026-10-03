%% I AM NOT DONE
-module(strings_and_binaries_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

to_bin_test() ->
    ?assertEqual(<<"abc">>, strings_and_binaries:to_bin("abc")).

to_str_test() ->
    ?assertEqual("abc", strings_and_binaries:to_str(<<"abc">>)).

greet_test() ->
    ?assertEqual(<<"Hello, Ann!">>, strings_and_binaries:greet(<<"Ann">>)).

shout_test() ->
    ?assertEqual(<<"HEY!">>, strings_and_binaries:shout(<<"hey">>)).

split_csv_test() ->
    ?assertEqual([<<"a">>, <<"b">>, <<"c">>], strings_and_binaries:split_csv(<<"a,b,c">>)),
    ?assertEqual([<<"solo">>], strings_and_binaries:split_csv(<<"solo">>)).

join_path_test() ->
    ?assertEqual(<<"usr/local/bin">>,
                 strings_and_binaries:join_path([<<"usr">>, <<"local">>, <<"bin">>])),
    ?assertEqual(<<"usr">>, strings_and_binaries:join_path([<<"usr">>])).

starts_with_test() ->
    ?assertEqual(true, strings_and_binaries:starts_with(<<"gen_server">>, <<"gen_">>)),
    ?assertEqual(false, strings_and_binaries:starts_with(<<"gen_server">>, <<"sup">>)),
    ?assertEqual(false, strings_and_binaries:starts_with(<<"ge">>, <<"gen_">>)).

to_iolist_size_test() ->
    ?assertEqual({4, <<"abcd">>}, strings_and_binaries:to_iolist_size(["ab", <<"c">>, [$d]])).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Three spellings, three types. Which comparisons are true?
reading_three_kinds_test() ->
    ?assertEqual(?TODO, "abc" =:= <<"abc">>),
    ?assertEqual(?TODO, "abc" =:= [$a, $b, $c]),
    ?assertEqual(?TODO, <<"abc">> =:= <<97, 98, 99>>).

%% length/1 is for lists, byte_size/1 for binaries. What are these?
reading_sizes_test() ->
    ?assertEqual(?TODO, length("hello")),
    ?assertEqual(?TODO, byte_size(<<"hello">>)),
    ?assertEqual(?TODO, iolist_size(["he", <<"ll">>, [$o]])).

%% The shell prints a list of small integers as a string. [104, 105] is
%% what string? And is [0, 1] printed as a string?
reading_list_is_string_test() ->
    ?assertEqual(?TODO, [104, 105] =:= "hi"),
    ?assertEqual(?TODO, io_lib:printable_list([0, 1])).

%% Binary concatenation syntax: what binary does this build?
reading_binary_concat_test() ->
    A = <<"ab">>,
    B = <<"cd">>,
    ?assertEqual(?TODO, <<A/binary, "-", B/binary>>).

%% Nested iolists flatten to a single binary. What is it?
reading_iolist_test() ->
    ?assertEqual(?TODO, iolist_to_binary([<<"a">>, ["b", [<<"c">>]], $d])).

%% binary:split without [global] splits only at the FIRST match.
reading_split_once_test() ->
    ?assertEqual(?TODO, binary:split(<<"a=b=c">>, <<"=">>)),
    ?assertEqual(?TODO, binary:split(<<"a=b=c">>, <<"=">>, [global])).

%% Multi-byte characters: a UTF-8 binary's byte_size is not its length.
%% "e with acute" is 2 bytes in UTF-8. Predict both numbers.
reading_utf8_test() ->
    Bin = <<"caf", 16#C3, 16#A9>>,
    ?assertEqual(?TODO, byte_size(Bin)),
    ?assertEqual(?TODO, string:length(Bin)).

%% integer_to_binary and friends. What does each give?
reading_conversions_test() ->
    ?assertEqual(?TODO, integer_to_binary(42)),
    ?assertEqual(?TODO, binary_to_integer(<<"17">>)),
    ?assertEqual(?TODO, atom_to_binary(ok)),
    ?assertEqual(?TODO, list_to_binary([<<"a">>, "b"])).
