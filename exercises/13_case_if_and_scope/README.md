# case, if, and variable scope

Erlang has `case` and `if`, but they behave differently from most languages:
they are expressions that return a value, `if` has no `else`, and variables
can only be bound once. This exercise is about reading control flow without
tripping on those three facts.

## Reading notes

- `case Expr of Pattern [when Guard] -> Body; ... end` is the workhorse. Each
  branch is a pattern (with an optional guard), branches are separated by `;`,
  and the value of the chosen body is the value of the whole `case`. The
  idiom you will see constantly is binding the result:

  ```erlang
  Reply = case maps:find(Key, State) of
              {ok, V} -> {ok, V};
              error -> {error, not_found}
          end,
  ```

- `if Guard1 -> ...; Guard2 -> ...; true -> ... end`. Each branch is a guard,
  not an arbitrary expression, so you cannot call your own functions there.
  The final `true ->` is the "else"; without it a non-matching `if` raises
  `if_clause`. Experienced Erlang programmers use `if` sparingly and prefer
  `case` or separate function clauses.
- **Single assignment.** `X = 1` binds X. A later `X = 2` is a *match* that
  fails with `{badmatch, 2}`. When you read `Pid = whereis(Name)` at the top
  and `Pid = ...` lower down in the same function, it is an assertion that the
  two are equal, not an update. Code that evolves a value uses numbered names:
  `State0`, `State1`, `State2`.
- **Unsafe variables.** If a variable is bound in only some branches of a
  `case`/`if`/`receive`, using it after the construct is a compile error:
  `variable 'Label' unsafe in 'case'`. Variables bound in *every* branch are
  fine, though most style guides still prefer returning the value from the
  `case`.
- `_` matches anything and binds nothing. `_Name` binds a variable but tells
  the compiler not to warn when it goes unused. Reading `_Reason` in a pattern
  is documentation: "there is a reason here, we ignore it".
- A guard that throws (e.g. `hd(X)` on a non-list) does not crash; it just
  evaluates to false and the next branch is tried.
- `begin ... end` groups several expressions into one; you will see it mostly
  inside macros and list comprehensions.

## Your task

1. Open `case_if_and_scope.erl`. Implement `grade/1`, `sign/1`, and
   `describe_list/1`.
2. `label/1` does not compile. Run the exercise, read the error, and rewrite
   the function so the `case` expression produces the value.
3. Open `case_if_and_scope_tests.erl` and replace every `?TODO` with your
   prediction.
4. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 13_case_if_and_scope
```

On Windows: `erlanglings run 13_case_if_and_scope`.

## Hints

<details>
<summary>Hints</summary>

- `grade/1`: `case Score of S when S >= 90 -> a; S when S >= 80 -> b; ... ; _ -> f end`.
- `sign/1`: `if N < 0 -> negative; N == 0 -> zero; true -> positive end`.
- `label/1`: `case N of 0 -> "zero"; _ -> "nonzero" end` as the whole function body.
- `describe_list/1`: three clauses: `[]`, `[X]`, and `List` with `{many, length(List)}`.
- A failed match raises `error:{badmatch, Value}` where Value is the right-hand side.
- `?assertError(Pattern, Expr)` matches the *reason* of an `error`-class exception.
- The `if` with no matching branch raises `error:if_clause`.

</details>
