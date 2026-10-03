# Idioms you will see every day

No new concepts here. This exercise is a vocabulary drill: a dozen tiny
helper functions written the way production Erlang is written, and the
standard-library behaviour they rely on. Fluent readers do not stop at any
of these; this exercise is about making sure you will not either.

## Reading notes

### Shapes that recur in every codebase

| you see | it means |
|---|---|
| `_ = f()` | "f returns something, I am deliberately ignoring it". Common before `ok.` at the end of cleanup code |
| `ok = f()` / `true = f()` / `{ok, V} = f()` | an **assertion**: crash right here with `badmatch` if the shape is wrong, instead of carrying a bad value further |
| `{ok, _} = Ok -> Ok` in a `case` | check the shape *and* bind the whole value in one pattern |
| `State0`, `State1`, `State2` | the same logical variable updated in steps; variables cannot be rebound |
| `#rec{field = X} = R` in a function head | bind both the field and the whole record |
| `maps:get(K, M, Default)` / `proplists:get_value(K, L, Default)` | lookups with defaults; `get_value` without a default returns the atom `undefined` |
| `lists:keyfind(K, 1, L)` | returns the **tuple** or `false` (not `undefined`) |
| `lists:foldl(fun(X, Acc) -> ... end, Acc0, L)` | the universal loop: build a map, a count, a reversed list |
| `[F(X) || X <- L]` vs `lists:foreach` | the first collects results, the second is for side effects and returns `ok` |
| `try ... catch Class:Reason:Stack -> ... end` | catch everything. `catch Reason ->` alone catches only `throw`s |
| `_ = (catch f())` | old-style "ignore any failure". Deprecated in new OTP but common in older code |
| `fun ?MODULE:handle/1` | a fun referring to the *latest loaded version* of the module (survives hot code loading); `fun handle/1` pins the current version |
| `erlang:phash2(Term, N)` | stable hashing into `0..N-1`, for sharding |
| `erlang:system_time(millisecond)` | wall-clock; `erlang:monotonic_time/1` for durations |
| `atom_to_binary(A, utf8)`, `integer_to_binary/1`, `binary_to_integer/1`, `unicode:characters_to_binary/1` | conversions at the edges; the inside of the system is binaries |
| `term_to_binary/1` and `binary_to_term/1` | serialise any term; what Mnesia, dets and most caches store |

### Standard-library facts to know cold

* **Term order.** Any two terms compare:
  `number < atom < reference < fun < port < pid < tuple < map < nil < list < bitstring`.
  So `lists:sort([b, 1, "a", {x}])` is `[1, b, {x}, "a"]`, and a sort never
  crashes on mixed types.
* **`=:=` vs `==`.** `1 =:= 1.0` is `false`, `1 == 1.0` is `true`. Code that
  compares against numbers from JSON usually wants `==`; everything else
  uses `=:=` (and `=/=`).
* **`andalso` / `orelse` short-circuit** and are allowed in guards. `and` /
  `or` evaluate both sides and are rarely what you want.
* **Strings are lists.** `hd("abc")` is `97`. `is_list("abc")` is true and
  `is_binary("abc")` is false. `length/1` is for lists, `byte_size/1` for
  binaries, `tuple_size/1` for tuples; `size/1` accepts tuples and binaries.
* **`binary:split/2` splits once**; add `[global]` to split everywhere.
  `string:split/3` with `all` is the equivalent for strings (and binaries).
* **Proplists accept bare atoms**: `[verbose, {port, 80}]` means
  `verbose` is `true`.
* **`maps:with/2` keeps keys, `maps:without/2` drops them.**
  `maps:update_with/4` is "update or insert default".
* **`string:to_integer("42abc")`** returns `{42, "abc"}`: the parsed prefix
  and the rest, or `{error, no_integer}`.

## Your task

`idioms.erl` is read-only. In `idioms_tests.erl`, replace every `?TODO`
with the value you expect. Part 1 reads the helpers; Part 2 is the standard
library.

## Run

```sh
./erlanglings run 32_idioms_reading
```

On Windows: `erlanglings run 32_idioms_reading`.

## Hints

<details><summary>Hints</summary>

* Q4: `{ok, 2}` and `{error, {error, badarith}}`: the inner `error` is the
  exception class.
* Q6: `nope` is not `{ok, _}`, so the search continues: `{ok, 2}`.
* Q7: `#{1 => {1, a}, 2 => {2, b}}`.
* Q11: `0`. With one bucket there is only one possible answer.
* Q12: `false`.
* Q16: `[1, 2.0, b, {x}, #{}, [], "a", <<"b">>]`.
* Q17: `[<<"a">>, <<"b,c">>]` then `[<<"a">>, <<"b">>, <<"c">>]`.
* Q20: `2`, `3`, and `length/1` on a binary raises `badarg`.
* Q23: `{42, "abc"}`.

</details>
