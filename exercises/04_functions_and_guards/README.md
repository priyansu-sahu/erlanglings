# Functions and Guards

Erlang has `if` and `case`, but most branching you will read is done with
multiple function clauses plus guards. A function with five clauses is a
decision table: scan the heads, and you know every situation the author
considered.

## Reading notes

```erlang
handle(Msg, State) when is_binary(Msg), byte_size(Msg) > 0 -> ...;
handle(Msg, State) when is_list(Msg); is_atom(Msg)         -> ...;
handle(_Msg, State)                                        -> ...
```

- **`when`** introduces a guard. In a guard, `,` means *and*, `;` means *or*.
  This is a different meaning from `,`/`;` in a body, and is the most common
  source of misreading.
- **Guards are restricted.** Only comparisons, arithmetic, boolean operators,
  type tests (`is_integer/1`, `is_binary/1`, ...) and a handful of BIFs such as
  `length/1`, `tuple_size/1`, `byte_size/1`, `element/2`, `map_get/2`. You will
  never see a user-defined function in a guard; if the author needed one, they
  used `case`.
- **A guard that raises counts as false.** `when length(X) > 2` with a
  non-list `X` does not crash, it just moves on to the next clause. This is
  sometimes used on purpose (`when hd(L) =:= foo` as "is a non-empty list
  starting with foo") and sometimes a hidden bug.
- **Order matters.** Clauses are tried top to bottom and the first match wins.
  The catch-all `f(_) ->` clause is always last. When reading, check whether
  an earlier clause shadows a later one.
- **`andalso` / `orelse`** short-circuit and are allowed in guards.
  `and` / `or` evaluate both sides. Modern code prefers `andalso`/`orelse`.
- **Falling off the end** of a function raises `function_clause`. In crash
  logs you will see things like
  `{function_clause, [{mod, handle, [bad_arg, state], ...}]}`: the args that
  no clause accepted are right there in the report.

Operators worth memorising because they differ from other languages:

| Erlang | Meaning              |
|--------|----------------------|
| `=:=`  | exactly equal        |
| `=/=`  | exactly not equal    |
| `==`   | equal, 1 == 1.0      |
| `/=`   | not equal (numeric)  |
| `=<`   | less than or equal   |
| `>=`   | greater than or equal|

## Your task

1. Implement the five functions in `functions_and_guards.erl` using multiple
   clauses and guards (not `if` or `case`).
2. Replace each `?TODO` in `functions_and_guards_tests.erl` with your
   prediction.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 04_functions_and_guards
```

On Windows (cmd/PowerShell): `erlanglings run 04_functions_and_guards`

## Hints

<details><summary>Hints</summary>

```erlang
sign(N) when N < 0 -> negative;
sign(0) -> zero;
sign(_) -> positive.
```

`describe/1` is one clause per type test: `is_integer`, `is_float`,
`is_atom`, `is_binary`, `is_list`, then a catch-all.

`clamp/3` needs three clauses: below Min, above Max, otherwise.

`safe_div(_, 0) -> {error, division_by_zero};` first, then the normal case.

</details>
