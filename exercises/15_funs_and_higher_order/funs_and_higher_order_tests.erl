%% I AM NOT DONE
-module(funs_and_higher_order_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').
-define(M, funs_and_higher_order).

make_adder_test() ->
    Add5 = ?M:make_adder(5),
    ?assert(is_function(Add5, 1)),
    ?assertEqual(12, Add5(7)),
    ?assertEqual(5, Add5(0)).

compose_test() ->
    Inc = fun(X) -> X + 1 end,
    Dbl = fun(X) -> X * 2 end,
    IncThenDbl = ?M:compose(Dbl, Inc),
    ?assertEqual(8, IncThenDbl(3)),
    DblThenInc = ?M:compose(Inc, Dbl),
    ?assertEqual(7, DblThenInc(3)).

apply_n_test() ->
    Dbl = fun(X) -> X * 2 end,
    ?assertEqual(8, ?M:apply_n(Dbl, 3, 1)),
    ?assertEqual(1, ?M:apply_n(Dbl, 0, 1)),
    ?assertEqual([3, 2, 1], ?M:apply_n(fun lists:reverse/1, 3, [1, 2, 3])).

call_each_test() ->
    Funs = [fun erlang:length/1, fun lists:reverse/1, fun lists:sum/1],
    ?assertEqual([3, [3, 2, 1], 6], ?M:call_each(Funs, [1, 2, 3])),
    ?assertEqual([], ?M:call_each([], anything)).

map_with_index_test() ->
    ?assertEqual([{1, a}, {2, b}, {3, c}],
                 ?M:map_with_index(fun(Pair) -> Pair end, [a, b, c])),
    ?assertEqual(["1:x", "2:y"],
                 ?M:map_with_index(fun({I, E}) -> integer_to_list(I) ++ ":" ++ E end,
                                   ["x", "y"])).

handler_for_test() ->
    ?assertEqual(<<"HELLO">>, (?M:handler_for(upper))(<<"hello">>)),
    ?assertEqual(5, (?M:handler_for(length))(<<"hello">>)),
    Echo = ?M:handler_for(echo),
    ?assertEqual({handled, <<"hi">>}, Echo(<<"hi">>)),
    %% `fun ?MODULE:handle/1` is an "external" fun: it remembers module,
    %% function and arity, and erlang:fun_info/2 can tell you so.
    ?assertEqual({type, external}, erlang:fun_info(Echo, type)),
    ?assertEqual({module, funs_and_higher_order}, erlang:fun_info(Echo, module)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Operators are functions too, living in the `erlang` module with quoted names.
operator_as_fun_test() ->
    Plus = fun erlang:'+'/2,
    ?assertEqual(?TODO, Plus(1, 2)),
    ?assertEqual(?TODO, lists:foldl(fun erlang:'*'/2, 1, [1, 2, 3, 4])).

%% Closures freeze the values they capture. X cannot be rebound, so a new
%% name is needed for the new value. What does F(1) return?
closure_capture_test() ->
    X = 10,
    F = fun(Y) -> X + Y end,
    X2 = X + 10,
    ?assertEqual(?TODO, F(1)),
    ?assertEqual(?TODO, X2).

%% apply/3 takes Module, Function, and a LIST of arguments. The list has one
%% element here -- the list [3, 1, 2]. What is the result?
apply_mfa_test() ->
    ?assertEqual(?TODO, apply(lists, max, [[3, 1, 2]])),
    ?assertEqual(?TODO, apply(erlang, tuple_size, [{a, b}])).

%% A named fun can call itself. What does this evaluate to?
named_fun_test() ->
    Fact = fun Fact(0) -> 1;
               Fact(N) -> N * Fact(N - 1)
           end,
    ?assertEqual(?TODO, Fact(5)).

%% Funs are matched by arity when checked with is_function/2.
is_function_arity_test() ->
    F = fun(_, _) -> ok end,
    ?assertEqual(?TODO, is_function(F, 2)),
    ?assertEqual(?TODO, is_function(F, 1)),
    ?assertEqual(?TODO, is_function(fun lists:reverse/1, 1)).

%% Calling a fun with the wrong number of arguments. Fill in the exception
%% reason's SHAPE (a pattern) -- the fun itself is not predictable.
badarity_test() ->
    F = fun(X) -> X end,
    ?assertError(?TODO, F(1, 2)).

%% lists:foldl/3 passes (Element, Accumulator) -- element first. The result
%% below depends on that order. What is it?
foldl_argument_order_test() ->
    ?assertEqual(?TODO, lists:foldl(fun(E, Acc) -> [E | Acc] end, [], [a, b, c])).
