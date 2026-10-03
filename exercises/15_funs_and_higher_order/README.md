# Funs and higher-order functions

Functions are values in Erlang. Production code passes them to `lists:map`,
`lists:foldl`, `maps:fold`, stores them in dispatch tables, and hands them
to processes. You need to recognize the five spellings of a fun and know what
a closure remembers.

## Reading notes

- Spellings you will meet:
  - `fun(X) -> X + 1 end` anonymous fun; can have several clauses and guards.
  - `fun helper/2` a reference to a local function.
  - `fun lists:reverse/1` a reference to a function in another module.
  - `fun ?MODULE:handle/1` an *external* reference through the module name.
    After a hot code upgrade this picks up the new version of `handle/1`, while
    `fun handle/1` keeps pointing at the old code. Long-running servers use the
    `?MODULE:` form deliberately.
  - `fun Loop(N) -> ... Loop(N - 1) end` a *named* fun, so it can recurse.
- Calling: `F(X)`, `apply(F, [X])`, or `apply(Mod, Fun, [Args])`. The third
  form (often written `erlang:apply/3` or seen in supervisor child specs as
  `{M, F, A}`) is how code calls a function it only knows by name at runtime.
- `M:F/A` in documentation, stack traces, and `-export([...])` means
  "function F in module M taking A arguments". Arity is part of the name:
  `start/0` and `start/1` are different functions.
- **Closures freeze values.** A fun captures the variables around it; since
  variables are immutable, the captured values can never change. This is why
  it is safe to send a fun to another process or store it in ETS.
- Operators are functions in the `erlang` module: `fun erlang:'+'/2`.
- Argument order for the common higher-order functions is worth memorizing:
  `lists:foldl(fun(Elem, Acc) -> ... end, Acc0, List)`,
  `lists:map(fun(Elem) -> ... end, List)`,
  `maps:fold(fun(Key, Value, Acc) -> ... end, Acc0, Map)`.
- Calling a fun with the wrong number of arguments raises
  `error:{badarity, {Fun, Args}}`; calling a non-fun raises `error:{badfun, V}`.

## Your task

1. Open `funs_and_higher_order.erl` and implement the six stubbed functions.
2. Open `funs_and_higher_order_tests.erl` and replace every `?TODO` with your
   prediction.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 15_funs_and_higher_order
```

On Windows: `erlanglings run 15_funs_and_higher_order`.

## Hints

<details>
<summary>Hints</summary>

- `make_adder(N) -> fun(X) -> X + N end.`
- `compose(F, G) -> fun(X) -> F(G(X)) end.`
- `apply_n(_F, 0, X) -> X; apply_n(F, N, X) -> apply_n(F, N - 1, F(X)).`
- `call_each(Funs, Arg) -> [F(Arg) || F <- Funs].`
- `map_with_index(F, L) -> lists:map(F, lists:zip(lists:seq(1, length(L)), L)).`
- `handler_for(echo) -> fun ?MODULE:handle/1;`
- `X2 = X + 10` creates a new variable; `F` still sees `X = 10`.
- badarity pattern: `{badarity, {_, [1, 2]}}` or simply `{badarity, _}`.
- foldl builds the accumulator from the left, so prepending reverses the list.

</details>
