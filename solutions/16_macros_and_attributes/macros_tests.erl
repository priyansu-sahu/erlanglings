-module(macros_tests).

-include_lib("eunit/include/eunit.hrl").
-include("macros.hrl").

max_retries_test() ->
    ?assertEqual(3, macros:max_retries()).

module_name_test() ->
    ?assertEqual(macros, macros:module_name()).

module_string_test() ->
    ?assertEqual("macros", macros:module_string()).

where_am_i_test() ->
    ?assertEqual({where_am_i, 0}, macros:where_am_i()).

is_port_test() ->
    ?assert(macros:is_port(80)),
    ?assert(macros:is_port(65535)),
    ?assertNot(macros:is_port(0)),
    ?assertNot(macros:is_port(70000)),
    ?assertNot(macros:is_port("80")).

retry_label_test() ->
    ?assertEqual("retry 1 of 3", macros:retry_label(1)),
    ?assertEqual("retry 3 of 3", macros:retry_label(3)).

with_timeout_test() ->
    ?assertEqual(5000, macros:with_timeout(default)),
    ?assertEqual(100, macros:with_timeout(100)).

version_test() ->
    ?assertEqual("1.2.0", macros:version()).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% ?MODULE expands to the name of the module it is written in. We are in the
%% TEST module now. What is ?MODULE here?
module_macro_here_test() ->
    ?assertEqual(macros_tests, ?MODULE).

%% ?MODULE_STRING is the same thing as a string.
module_string_macro_test() ->
    ?assertEqual("macros_tests", ?MODULE_STRING).

%% ?FUNCTION_NAME inside this test function.
function_name_macro_test() ->
    ?assertEqual(function_name_macro_test, ?FUNCTION_NAME).

%% ?LINE is an integer. is_integer(?LINE) is...
line_macro_test() ->
    ?assertEqual(true, is_integer(?LINE)).

%% The ?IS_PORT macro can be used as a plain expression too (it's just text).
guard_macro_as_expression_test() ->
    ?assertEqual(true, ?IS_PORT(443)),
    ?assertEqual(false, ?IS_PORT(-1)).

%% DEBUG is NOT defined in this build, so ?DEBUG_LOG expands to the -else branch.
%% What does the expression evaluate to?
ifdef_test() ->
    ?assertEqual(ok, ?DEBUG_LOG("x = ~p", [1])).

%% Every module gets module_info/0 and module_info/1 for free, and exports
%% them. Does the export list of `macros` contain {module_info, 1}?
module_info_exported_test() ->
    Exports = macros:module_info(exports),
    ?assertEqual(true, lists:member({module_info, 1}, Exports)).

%% Custom attributes are stored as {Name, Values} where Values is a list
%% (a non-list value is wrapped). What does keyfind return for `author`?
custom_attribute_test() ->
    Attrs = macros:module_info(attributes),
    ?assertEqual({author, [erlanglings]}, lists:keyfind(author, 1, Attrs)).
