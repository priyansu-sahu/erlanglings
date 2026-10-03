%% Test modules end in _tests and use EUnit. You do not need to edit this file.
%% Any function whose name ends in _test is picked up as a test case.
-module(hello_world_tests).

-include_lib("eunit/include/eunit.hrl").

hello_test() ->
    ?assertEqual("Hello, World!", hello_world:hello()).
