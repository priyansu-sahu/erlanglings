# Recursion

There are no loops. Every iteration in Erlang is a recursive function, and
every long-running process is a function that calls itself with new state.
Reading recursion fluently is not optional; this exercise drills the two
shapes that account for almost all of it.

## Reading notes

**Body recursion** does the work after the call returns:

```erlang
map(_F, []) -> [];
map(F, [H | T]) -> [F(H) | map(F, T)].
```

**Tail recursion with an accumulator** does the work before the call and
returns the accumulator at the base case:

```erlang
sum(List) -> sum(List, 0).            % public API, arity N
sum([], Acc) -> Acc;                  % base case: return what we built
sum([H | T], Acc) -> sum(T, Acc + H). % step: last thing is the recursive call
```

Recognise the pattern in production modules:

- `foo/1` is exported and calls `foo/2` (or `do_foo/2`, `foo_loop/2`) with a
  starting accumulator like `[]`, `0`, `#{}`, or a record. The arity-2 version
  is private and does the work.
- A list accumulated with `[H | Acc]` is backwards, so the base case returns
  `lists:reverse(Acc)`. This is not a bug.
- Multiple accumulators are passed as separate arguments or a tuple:
  `split(L, Evens, Odds)`.
- A process main loop is tail recursion that never ends:

  ```erlang
  loop(State) ->
      receive
          Msg -> loop(handle(Msg, State))
      end.
  ```

  `gen_server` hides this loop from you, but it is there.

- **Named funs** (`fun Walk(X) -> ... Walk(Y) end`, since OTP 17) let a
  fun call itself. The tests use them to keep each example self-contained;
  in modules, people just write a helper function.

Gotchas:

- **Find the base case first.** It tells you the type of the result and
  usually the direction of the accumulation.
- **A missing base case** does not loop forever; it crashes with
  `function_clause` when the list runs out and nothing matches `[]`.
- **`++` copies its left operand.** `Acc ++ [X]` inside a loop is quadratic.
  Idiomatic code uses `[X | Acc]` and reverses once. When you see `++` in a
  loop in a code review, that is the thing to question.
- Tail calls do not grow the stack, so `loop/1` running for months is fine.
  Body recursion over a few thousand elements is also fine; do not rewrite
  clear code for imagined performance.

## Your task

1. Implement the seven functions in `recursion.erl`. Use a tail-recursive
   helper with an accumulator where the comment asks for one.
2. Replace each `?TODO` in `recursion_tests.erl`. Trace the small examples on
   paper before running.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 06_recursion
```

On Windows (cmd/PowerShell): `erlanglings run 06_recursion`

## Hints

<details><summary>Hints</summary>

```erlang
reverse(L) -> reverse(L, []).
reverse([], Acc) -> Acc;
reverse([H | T], Acc) -> reverse(T, [H | Acc]).
```

`take/2`: base cases `take(0, _) -> []` and `take(_, []) -> []`, then
`take(N, [H | T]) -> [H | take(N - 1, T)]`.

`range/2`: `range(From, To) when From > To -> []; range(From, To) -> [From | range(From + 1, To)]`.

`flatten/1`: `flatten([H | T]) when is_list(H) -> flatten(H) ++ flatten(T);`
then the non-list head case and the `[]` case.

</details>
