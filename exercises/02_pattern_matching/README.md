# Pattern Matching

Pattern matching is the single most important thing to understand when reading
Erlang. `=` does not assign. Function heads do not just name parameters. Both
*match*: they compare a pattern against a value, binding variables along the
way, and crash (or fall through to the next clause) when the shapes disagree.

## Reading notes

Where you will see patterns in production code:

- **Function heads.** Most Erlang functions destructure their arguments right
  in the head and have several clauses, one per shape:

  ```erlang
  handle_info({tcp, Sock, Data}, State) -> ...;
  handle_info({tcp_closed, Sock}, State) -> ...;
  handle_info(_Other, State) -> ...
  ```

  When reading, treat the clause heads as a table of contents: "this function
  handles tcp data, tcp close, and everything else".

- **Asserting assumptions.** `{ok, Pid} = supervisor:start_child(...)` says
  "this must succeed; if it doesn't, crash here". It is deliberate. Erlang
  code does not check every return value; it matches the one it expects and
  lets everything else crash loudly ("let it crash").

- **`case` expressions.** `case Expr of Pattern1 -> ...; Pattern2 -> ... end`.
  Patterns are tried top to bottom; the first that matches wins.

- **Receive.** `receive {Ref, Reply} -> ... end` only takes messages that fit
  the pattern. Exercise 19.

Idioms to recognise on sight:

| Pattern                 | Means                                             |
|-------------------------|---------------------------------------------------|
| `[H \| T]`               | non-empty list: first element and the rest        |
| `[]`                    | the empty list (so `[H \| T]` + `[]` is complete)  |
| `[A, B \| Rest]`         | list with at least two elements                   |
| `{ok, V}` / `{error, R}`| the standard success/failure tuples               |
| `_`                     | match anything, don't bind                        |
| `_Reason`               | match anything, named for documentation           |
| `{K, K}`                | two positions must be equal                       |
| `#{id := Id}`           | map must contain key `id`; bind its value         |
| `#state{count = N}`     | record field (exercise 12)                        |
| `<<Len:8, Body/binary>>`| binary with a length prefix (exercise 10)         |
| `"GET " ++ Rest`        | string starting with that prefix                  |
| `Var = Pattern`         | bind the whole value *and* destructure it         |

Gotchas:

- `X = 5` when `X` is already bound is a *comparison*. It succeeds if X is 5
  and raises `badmatch` otherwise. Since OTP 26 the compiler warns when this is
  probably accidental, but older code relies on it.
- Maps use `:=` in patterns (`#{k := V}`) and `=>` when building
  (`#{k => V}`). Mixing them up is a compile error.
- A pattern cannot call functions. `{ok, length(L)} = ...` is a syntax error.
  Guards (exercise 04) are how you add conditions.

## Your task

1. Implement the six functions in `pattern_matching.erl`. Do the
   destructuring in the function head wherever possible.
2. Replace every `?TODO` in `pattern_matching_tests.erl` with your prediction.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 02_pattern_matching
```

On Windows (cmd/PowerShell): `erlanglings run 02_pattern_matching`

## Hints

<details><summary>Hints</summary>

- `match_tuple({A, B}) -> A + B.`
- A list head: `match_list([H | _]) -> H.`
- Map pattern: `match_map(#{key := V}) -> V.`
- `tagged/1` needs two clauses separated by `;`:
  ```erlang
  tagged({ok, V}) -> V;
  tagged({error, _}) -> failed.
  ```
- For the `reading_rebind_test`: `X = 2` with `X` already bound to `1` raises
  the error `{badmatch, 2}`. The `catch` clause turns that into
  `{caught, {badmatch, 2}}`.

</details>
