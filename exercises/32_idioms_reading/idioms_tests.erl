%% I AM NOT DONE
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
     ?_assertEqual(?TODO, idioms:get_opt(port, [{port, 80}, {host, "x"}], 8080)),
     ?_assertEqual(?TODO, idioms:get_opt(port, #{port => 443}, 8080)),
     ?_assertEqual(?TODO, idioms:get_opt(port, [], 8080)),

     %% Q2. ensure_binary/1 on a string, an atom and an integer.
     ?_assertEqual(?TODO, idioms:ensure_binary("abc")),
     ?_assertEqual(?TODO, idioms:ensure_binary(ok)),
     ?_assertEqual(?TODO, idioms:ensure_binary(42)),

     %% Q3. to_int/1 on a binary.
     ?_assertEqual(?TODO, idioms:to_int(<<"42">>)),

     %% Q4. safe_call/1: a fun that returns, and one that crashes with
     %%     badarith. Remember the shape {error, {Class, Reason}}.
     ?_assertEqual(?TODO, idioms:safe_call(fun() -> 1 + 1 end)),
     ?_assertEqual(?TODO, idioms:safe_call(fun() -> 1 + opaque(a) end)),

     %% Q5. swallow/1 with a fun that raises.
     ?_assertEqual(?TODO, idioms:swallow(fun() -> error(boom) end)),

     %% Q6. first_ok/1: the first fun returns a bare atom (not {ok, _}).
     ?_assertEqual(?TODO, idioms:first_ok([fun() -> nope end,
                                           fun() -> {ok, 2} end,
                                           fun() -> {ok, 3} end])),
     ?_assertEqual(?TODO, idioms:first_ok([])),

     %% Q7. index_by/2 keyed on the first tuple element.
     ?_assertEqual(?TODO, idioms:index_by(fun({Id, _}) -> Id end, [{1, a}, {2, b}])),

     %% Q8. bump/2 on a missing key and on an existing key.
     ?_assertEqual(?TODO, idioms:bump(x, #{})),
     ?_assertEqual(?TODO, idioms:bump(x, #{x => 4})),

     %% Q9. pipe/2: trim, then lowercase.
     ?_assertEqual(?TODO, idioms:pipe("  Hi  ", [fun string:trim/1, fun string:lowercase/1])),

     %% Q10. is_normal_exit/1.
     ?_assertEqual(?TODO, idioms:is_normal_exit({shutdown, drained})),
     ?_assertEqual(?TODO, idioms:is_normal_exit(killed)),

     %% Q11. hash_bucket/2 with a single bucket: phash2(_, 1) can only be...?
     ?_assertEqual(?TODO, idioms:hash_bucket(<<"alice">>, 1))
    ].

%%% ------------------------------------------------------------------
%%% Part 2: standard library behaviour you need to know cold
%%% ------------------------------------------------------------------

stdlib_test_() ->
    [
     %% Q12. lists:keyfind/3 on a missing key returns... (not undefined!)
     ?_assertEqual(?TODO, lists:keyfind(z, 1, [{a, 1}, {b, 2}])),

     %% Q13. proplists: a bare atom in a proplist means {Atom, true}.
     ?_assertEqual(?TODO, proplists:get_value(verbose, [verbose, {port, 1}])),
     ?_assertEqual(?TODO, proplists:get_value(missing, [verbose])),
     ?_assertEqual(?TODO, proplists:get_bool(quiet, [verbose])),

     %% Q14. Equality: =:= is exact, == compares numbers by value.
     ?_assertEqual(?TODO, opaque(1) =:= 1.0),
     ?_assertEqual(?TODO, opaque(1) == 1.0),

     %% Q15. andalso / orelse short-circuit: the right side never runs.
     ?_assertEqual(?TODO, opaque(false) andalso error(boom)),
     ?_assertEqual(?TODO, opaque(true) orelse error(boom)),

     %% Q16. Term order. Every term is comparable with every other:
     %%   number < atom < reference < fun < port < pid < tuple < map < nil < list < bitstring
     %% (nil is the empty list []). Sort this list.
     ?_assertEqual(?TODO, lists:sort([b, 1, "a", {x}, <<"b">>, [], #{}, 2.0])),

     %% Q17. binary:split/2 splits ONCE by default; [global] splits all.
     ?_assertEqual(?TODO, binary:split(<<"a,b,c">>, <<",">>)),
     ?_assertEqual(?TODO, binary:split(<<"a,b,c">>, <<",">>, [global])),

     %% Q18. string:split/3 with `all' on a charlist.
     ?_assertEqual(?TODO, string:split("a,b,c", ",", all)),

     %% Q19. hd/1 of a string is a character code. $a is 97.
     ?_assertEqual(?TODO, hd(opaque("abc"))),
     ?_assertEqual(?TODO, is_list(opaque("abc"))),
     ?_assertEqual(?TODO, is_binary(opaque("abc"))),

     %% Q20. Sizes: size/1 works on tuples AND binaries; length/1 only on
     %%      lists. What does length/1 raise on a binary?
     ?_assertEqual(?TODO, size(opaque({a, b}))),
     ?_assertEqual(?TODO, size(opaque(<<1, 2, 3>>))),
     ?_assertError(?TODO, length(opaque(<<"abc">>))),

     %% Q21. element/2 and setelement/3 are 1-indexed.
     ?_assertEqual(?TODO, element(2, opaque({a, b, c}))),
     ?_assertEqual(?TODO, setelement(1, opaque({a, b}), z)),

     %% Q22. maps:with/2 keeps only the given keys, maps:without/2 drops them.
     ?_assertEqual(?TODO, maps:with([a], #{a => 1, b => 2})),
     ?_assertEqual(?TODO, maps:without([a], #{a => 1, b => 2})),

     %% Q23. string:to_integer/1 parses a prefix and returns the rest.
     ?_assertEqual(?TODO, string:to_integer("42abc")),

     %% Q24. term_to_binary/binary_to_term round-trip: the standard way to
     %%      serialise any term (ETS on disk, message queues, caches).
     ?_assertEqual(?TODO, binary_to_term(term_to_binary(#{a => [1, 2]}))),

     %% Q25. lists:duplicate/2.
     ?_assertEqual(?TODO, lists:duplicate(3, x))
    ].
