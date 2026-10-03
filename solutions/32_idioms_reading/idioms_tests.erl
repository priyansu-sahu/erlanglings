-module(idioms_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% Part 1 reads the helpers in idioms.erl. Part 2 is the standard library
%% behaviour those helpers rely on; it is the stuff you must simply know.
%%
%% opaque/1 hides a constant from the compiler's optimiser so that the
%% deliberately-failing expressions below do not produce compile warnings.
%% (It changes nothing about the values.)
opaque(Term) -> binary_to_term(term_to_binary(Term)).

%%% ------------------------------------------------------------------
%%% Part 1: the helpers
%%% ------------------------------------------------------------------

helpers_test_() ->
    [
     %% Q1. get_opt/3 with a proplist, with a map, and with a missing key.
     ?_assertEqual(80, idioms:get_opt(port, [{port, 80}, {host, "x"}], 8080)),
     ?_assertEqual(443, idioms:get_opt(port, #{port => 443}, 8080)),
     ?_assertEqual(8080, idioms:get_opt(port, [], 8080)),

     %% Q2. ensure_binary/1 on a string, an atom and an integer.
     ?_assertEqual(<<"abc">>, idioms:ensure_binary("abc")),
     ?_assertEqual(<<"ok">>, idioms:ensure_binary(ok)),
     ?_assertEqual(<<"42">>, idioms:ensure_binary(42)),

     %% Q3. to_int/1 on a binary.
     ?_assertEqual(42, idioms:to_int(<<"42">>)),

     %% Q4. safe_call/1: a fun that returns, and one that crashes with
     %%     badarith. Remember the shape {error, {Class, Reason}}.
     ?_assertEqual({ok, 2}, idioms:safe_call(fun() -> 1 + 1 end)),
     ?_assertEqual({error, {error, badarith}}, idioms:safe_call(fun() -> 1 + opaque(a) end)),

     %% Q5. swallow/1 with a fun that raises.
     ?_assertEqual(ok, idioms:swallow(fun() -> error(boom) end)),

     %% Q6. first_ok/1: the first fun returns a bare atom (not {ok, _}).
     ?_assertEqual({ok, 2}, idioms:first_ok([fun() -> nope end,
                                             fun() -> {ok, 2} end,
                                             fun() -> {ok, 3} end])),
     ?_assertEqual({error, none}, idioms:first_ok([])),

     %% Q7. index_by/2 keyed on the first tuple element.
     ?_assertEqual(#{1 => {1, a}, 2 => {2, b}},
                   idioms:index_by(fun({Id, _}) -> Id end, [{1, a}, {2, b}])),

     %% Q8. bump/2 on a missing key and on an existing key.
     ?_assertEqual(#{x => 1}, idioms:bump(x, #{})),
     ?_assertEqual(#{x => 5}, idioms:bump(x, #{x => 4})),

     %% Q9. pipe/2: trim, then lowercase.
     ?_assertEqual("hi", idioms:pipe("  Hi  ", [fun string:trim/1, fun string:lowercase/1])),

     %% Q10. is_normal_exit/1.
     ?_assertEqual(true, idioms:is_normal_exit({shutdown, drained})),
     ?_assertEqual(false, idioms:is_normal_exit(killed)),

     %% Q11. hash_bucket/2 with a single bucket: phash2(_, 1) can only be...?
     ?_assertEqual(0, idioms:hash_bucket(<<"alice">>, 1))
    ].

%%% ------------------------------------------------------------------
%%% Part 2: standard library behaviour you need to know cold
%%% ------------------------------------------------------------------

stdlib_test_() ->
    [
     %% Q12. lists:keyfind/3 on a missing key returns... (not undefined!)
     ?_assertEqual(false, lists:keyfind(z, 1, [{a, 1}, {b, 2}])),

     %% Q13. proplists: a bare atom in a proplist means {Atom, true}.
     ?_assertEqual(true, proplists:get_value(verbose, [verbose, {port, 1}])),
     ?_assertEqual(undefined, proplists:get_value(missing, [verbose])),
     ?_assertEqual(false, proplists:get_bool(quiet, [verbose])),

     %% Q14. Equality: =:= is exact, == compares numbers by value.
     ?_assertEqual(false, opaque(1) =:= 1.0),
     ?_assertEqual(true, opaque(1) == 1.0),

     %% Q15. andalso / orelse short-circuit: the right side never runs.
     ?_assertEqual(false, opaque(false) andalso error(boom)),
     ?_assertEqual(true, opaque(true) orelse error(boom)),

     %% Q16. Term order. Every term is comparable with every other:
     %%   number < atom < reference < fun < port < pid < tuple < map < nil < list < bitstring
     %% (nil is the empty list []). Sort this list.
     ?_assertEqual([1, 2.0, b, {x}, #{}, [], "a", <<"b">>],
                   lists:sort([b, 1, "a", {x}, <<"b">>, [], #{}, 2.0])),

     %% Q17. binary:split/2 splits ONCE by default; [global] splits all.
     ?_assertEqual([<<"a">>, <<"b,c">>], binary:split(<<"a,b,c">>, <<",">>)),
     ?_assertEqual([<<"a">>, <<"b">>, <<"c">>], binary:split(<<"a,b,c">>, <<",">>, [global])),

     %% Q18. string:split/3 with `all' on a charlist.
     ?_assertEqual(["a", "b", "c"], string:split("a,b,c", ",", all)),

     %% Q19. hd/1 of a string is a character code. $a is 97.
     ?_assertEqual(97, hd(opaque("abc"))),
     ?_assertEqual(true, is_list(opaque("abc"))),
     ?_assertEqual(false, is_binary(opaque("abc"))),

     %% Q20. Sizes: size/1 works on tuples AND binaries; length/1 only on
     %%      lists. What does length/1 raise on a binary?
     ?_assertEqual(2, size(opaque({a, b}))),
     ?_assertEqual(3, size(opaque(<<1, 2, 3>>))),
     ?_assertError(badarg, length(opaque(<<"abc">>))),

     %% Q21. element/2 and setelement/3 are 1-indexed.
     ?_assertEqual(b, element(2, opaque({a, b, c}))),
     ?_assertEqual({z, b}, setelement(1, opaque({a, b}), z)),

     %% Q22. maps:with/2 keeps only the given keys, maps:without/2 drops them.
     ?_assertEqual(#{a => 1}, maps:with([a], #{a => 1, b => 2})),
     ?_assertEqual(#{b => 2}, maps:without([a], #{a => 1, b => 2})),

     %% Q23. string:to_integer/1 parses a prefix and returns the rest.
     ?_assertEqual({42, "abc"}, string:to_integer("42abc")),

     %% Q24. term_to_binary/binary_to_term round-trip: the standard way to
     %%      serialise any term (ETS on disk, message queues, caches).
     ?_assertEqual(#{a => [1, 2]}, binary_to_term(term_to_binary(#{a => [1, 2]}))),

     %% Q25. lists:duplicate/2.
     ?_assertEqual([x, x, x], lists:duplicate(3, x))
    ].
