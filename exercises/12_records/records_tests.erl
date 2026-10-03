%% I AM NOT DONE
-module(records_tests).

-include_lib("eunit/include/eunit.hrl").
%% Test modules need the same record definition to build #user{} values.
-include("user.hrl").

-define(TODO, '__TODO__').

new_test() ->
    U = records:new(7, <<"ann">>),
    ?assertEqual(7, U#user.id),
    ?assertEqual(<<"ann">>, U#user.name),
    ?assertEqual(offline, U#user.status),
    ?assertEqual([], U#user.devices).

go_online_test() ->
    U = records:go_online(records:new(1, <<"bob">>)),
    ?assertEqual(online, U#user.status),
    %% the other fields are untouched
    ?assertEqual(<<"bob">>, U#user.name).

is_online_test() ->
    U = records:new(1, <<"bob">>),
    ?assertNot(records:is_online(U)),
    ?assert(records:is_online(records:go_online(U))).

add_device_test() ->
    U0 = records:new(1, <<"cat">>),
    U1 = records:add_device(U0, <<"phone">>),
    U2 = records:add_device(U1, <<"laptop">>),
    ?assertEqual([<<"laptop">>, <<"phone">>], U2#user.devices),
    %% U0 was not mutated -- records are immutable tuples
    ?assertEqual([], U0#user.devices).

name_test() ->
    ?assertEqual(<<"dan">>, records:name(records:new(2, <<"dan">>))).

to_map_test() ->
    U = records:go_online(records:new(3, <<"eve">>)),
    ?assertEqual(#{id => 3, name => <<"eve">>, status => online, devices => []},
                 records:to_map(U)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% A record is a tuple whose first element is the record name.
record_is_tuple_test() ->
    U = #user{id = 1, name = <<"ann">>},
    ?assertEqual(?TODO, is_tuple(U)),
    ?assertEqual(?TODO, element(1, U)).

%% How many elements does the tuple have? (record name + every field)
record_size_test() ->
    U = #user{id = 1, name = <<"ann">>},
    ?assertEqual(?TODO, tuple_size(U)).

%% `#user.status` is the 1-based POSITION of the field in the tuple.
field_index_test() ->
    ?assertEqual(?TODO, #user.id),
    ?assertEqual(?TODO, #user.status).

%% Fields you don't set take their default; fields with no default are `undefined`.
defaults_test() ->
    U = #user{},
    ?assertEqual(?TODO, U#user.status),
    ?assertEqual(?TODO, U#user.id).

%% The full tuple form. Write out exactly what the record expands to.
raw_tuple_test() ->
    ?assertEqual(?TODO, #user{id = 9, name = <<"zed">>, status = online}).

%% `is_record/2` checks the tag and the size.
is_record_test() ->
    ?assertEqual(?TODO, is_record(#user{}, user)),
    ?assertEqual(?TODO, is_record({user, 1}, user)).
