-module(error_handling_tests).

-include_lib("eunit/include/eunit.hrl").

%% Old-style `catch Expr` is deprecated since OTP 28/29 and the compiler warns
%% about it. It is still everywhere in older codebases, so we practice reading
%% it here and silence the warning for this module only.
-compile(nowarn_deprecated_catch).

%% `opaque/1` hides a value from the compiler's constant folding.
-export([opaque/1]).
opaque(X) -> X.

safe_div_test() ->
    ?assertEqual({ok, 3}, error_handling:safe_div(7, 2)),
    ?assertEqual({error, division_by_zero}, error_handling:safe_div(7, 0)).

classify_test() ->
    ?assertEqual({ok, 42}, error_handling:classify(fun() -> 42 end)),
    ?assertEqual({throw, oops}, error_handling:classify(fun() -> throw(oops) end)),
    ?assertEqual({error, badarith}, error_handling:classify(fun() -> 1 / opaque(0) end)),
    ?assertEqual({error, {badmatch, b}},
                 error_handling:classify(fun() -> a = opaque(b) end)),
    ?assertEqual({exit, shutdown}, error_handling:classify(fun() -> exit(shutdown) end)).

with_cleanup_normal_test() ->
    Self = self(),
    ?assertEqual(done, error_handling:with_cleanup(fun() -> done end, Self)),
    receive cleanup_done -> ok after 100 -> ?assert(false) end.

with_cleanup_raises_test() ->
    Self = self(),
    ?assertThrow(bail, error_handling:with_cleanup(fun() -> throw(bail) end, Self)),
    receive cleanup_done -> ok after 100 -> ?assert(false) end,
    ?assertError(badarith, error_handling:with_cleanup(fun() -> 1 / opaque(0) end, Self)),
    receive cleanup_done -> ok after 100 -> ?assert(false) end.

parse_int_test() ->
    ?assertEqual({ok, 42}, error_handling:parse_int("42")),
    ?assertEqual({ok, -7}, error_handling:parse_int("-7")),
    ?assertEqual({error, badarg}, error_handling:parse_int("4x2")),
    ?assertEqual({error, badarg}, error_handling:parse_int("")).

retry_test() ->
    %% A fun that fails twice (once by raising, once by {error, _}) then succeeds.
    Counter = counters:new(1, []),
    Flaky = fun() ->
                    counters:add(Counter, 1, 1),
                    case counters:get(Counter, 1) of
                        1 -> error(boom);
                        2 -> {error, not_yet};
                        _ -> {ok, finally}
                    end
            end,
    ?assertEqual({ok, finally}, error_handling:retry(Flaky, 5)),
    ?assertEqual(3, counters:get(Counter, 1)),
    ?assertEqual({error, retries_exhausted},
                 error_handling:retry(fun() -> {error, nope} end, 3)),
    ?assertEqual({error, retries_exhausted},
                 error_handling:retry(fun() -> throw(nope) end, 3)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Old-style catch. What does `catch throw(x)` evaluate to?
old_catch_throw_test() ->
    ?assertEqual(x, catch throw(opaque(x))).

%% And `catch exit(x)`? (Exits have no stack trace.)
old_catch_exit_test() ->
    ?assertEqual({'EXIT', x}, catch exit(opaque(x))).

%% And `catch error(x)`? Errors carry a stack trace, so write the SHAPE:
%% use `_` for the part you cannot predict.
old_catch_error_test() ->
    ?assertMatch({'EXIT', {x, _}}, catch error(opaque(x))).

%% The runtime raises error:badarith for division by zero.
old_catch_badarith_test() ->
    ?assertMatch({'EXIT', {badarith, _}}, catch 1 / opaque(0)).

%% If nothing is raised, `catch` is transparent.
old_catch_value_test() ->
    ?assertEqual(2, catch opaque(1) + 1).

%% In `try Expr of Pattern -> Body catch ... end`, the `of` body is NOT
%% protected by the catch. Which clause of the OUTER try handles this?
try_of_not_protected_test() ->
    R = try
            try opaque(1) of
                1 -> throw(from_of_body)
            catch
                throw:from_of_body -> inner_caught
            end
        catch
            throw:from_of_body -> outer_caught
        end,
    ?assertEqual(outer_caught, R).

%% A catch clause with no class only matches throws. Does `catch oops -> ...`
%% catch error(oops)? Fill in the result.
bare_catch_clause_test() ->
    R = try
            try error(opaque(oops))
            catch
                oops -> caught_by_bare_clause
            end
        catch
            error:oops -> caught_by_outer
        end,
    ?assertEqual(caught_by_outer, R).

%% `after` runs, but its value is discarded. What does the try return?
after_value_discarded_test() ->
    R = try opaque(body_value)
        after
            after_value
        end,
    ?assertEqual(body_value, R).
