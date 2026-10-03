# The lists Module

Hand-rolled recursion is for the cases nothing in `lists` covers. Day to day,
most list code you read is a chain of `lists:map`, `lists:filter`,
`lists:foldl`, `lists:keyfind` and friends. Knowing their argument order and
return shapes by heart turns a dense line into a sentence.

## Reading notes

The ones you will see most, with the detail that matters when reading:

| Call                               | Returns                       | Watch out for                       |
|------------------------------------|-------------------------------|-------------------------------------|
| `lists:map(F, L)`                  | new list                      | fun first, list last                |
| `lists:filter(Pred, L)`            | elements where Pred is true   |                                     |
| `lists:foldl(F, Acc0, L)`          | final accumulator             | `F(Elem, Acc)`, element first       |
| `lists:foldr(F, Acc0, L)`          | final accumulator             | runs right to left                  |
| `lists:foreach(F, L)`              | `ok`                          | side effects only                   |
| `lists:keyfind(Key, N, L)`         | the tuple, or `false`         | N is the 1-based key position       |
| `lists:keysort(N, L)` / `keydelete` / `keystore` / `keyreplace` | list | same positional convention    |
| `lists:member(X, L)`               | `true` / `false`              |                                     |
| `lists:nth(N, L)`                  | element                       | 1-indexed; crashes if out of range  |
| `lists:sort(L)` / `lists:usort(L)` | sorted list                   | `usort` also dedups; term order     |
| `lists:sort(F, L)`                 | sorted list                   | `F(A, B)` returns true if A =< B    |
| `lists:zip(L1, L2)` / `unzip`      | list of pairs / pair of lists | zip crashes on unequal lengths (OTP < 26) |
| `lists:partition(Pred, L)`         | `{Yes, No}`                   |                                     |
| `lists:split(N, L)`                | `{First, Rest}`               |                                     |
| `lists:seq(A, B)`                  | `[A..B]`                      |                                     |
| `lists:flatten(L)` / `lists:append(L1, L2)` | list                 | `append` is `++`                    |

How it reads in practice:

```erlang
Active = [U || U <- Users, is_active(U)],                 % comprehension, ex 08
Names  = lists:map(fun user_name/1, Active),              % local fun by name
Total  = lists:foldl(fun(U, Acc) -> Acc + age(U) end, 0, Active),
case lists:keyfind(Id, #user.id, Users) of               % record field index, ex 12
    #user{} = U -> {ok, U};
    false       -> error
end
```

Gotchas:

- **Fold argument order.** `F(Elem, Acc)`, element first. The initial
  accumulator comes *before* the list in the call.
- **`foldl` building a list reverses it.** `foldl(fun(X, A) -> [X|A] end, [], L)`
  is `lists:reverse(L)`. That is why you see `lists:reverse(lists:foldl(...))`.
- **`keyfind` returns the whole tuple**, not the value, and `false` (not
  `error` or `undefined`) when missing.
- **1-indexing everywhere**: `lists:nth`, `element`, key positions.
- **Term order in sort.** Numbers sort before atoms before tuples before
  lists. `lists:sort([b, 2, a, 1])` is well-defined.
- `lists:sort/2` takes a "less than or equal" function. `fun(A, B) -> A >= B end`
  sorts descending.

## Your task

1. Implement the eight functions in `lists_module.erl` using `lists`
   functions rather than hand-written recursion.
2. Replace each `?TODO` in `lists_module_tests.erl`.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 07_lists_module
```

On Windows (cmd/PowerShell): `erlanglings run 07_lists_module`

## Hints

<details><summary>Hints</summary>

- `doubles(L) -> lists:map(fun(X) -> X * 2 end, L).`
- `total(L) -> lists:foldl(fun(X, Acc) -> Acc + X end, 0, L).`
- `names(Users) -> lists:map(fun({Name, _Age}) -> Name end, Users).`
- `oldest/1`: `{_Age, Name} = lists:max([{A, N} || {N, A} <- Users]), Name.`
  or a `foldl` carrying the best tuple so far.
- `by_name/2`: `case lists:keyfind(Name, 1, Users) of {_, Age} -> {ok, Age}; false -> error end`.
- `top_n(N, L) -> lists:sublist(lists:reverse(lists:sort(L)), N).`

</details>
