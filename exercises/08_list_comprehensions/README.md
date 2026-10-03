# List Comprehensions

`[Expr || Pattern <- List, Filter]` is Erlang's one-line map/filter. It is
compact, extremely common, and hides one trick (pattern generators) that
newcomers misread for weeks.

## Reading notes

Anatomy:

```erlang
[ Name                       % 1. what to build for each element
  || {Name, Age} <- Users,   % 2. generator: pattern <- list
     Age >= 18,              % 3. filter: boolean expression
     Name =/= <<"root">> ]   % 4. more filters, ANDed
```

Read `||` as "for each" and `<-` as "drawn from".

The things to internalise:

- **Pattern generators filter silently.** `[V || {ok, V} <- Results]` keeps
  only the `{ok, _}` tuples; everything else is skipped without error. When
  reading, ask "what does this pattern *exclude*?" as well as "what does it
  bind?".
- **Multiple generators nest.** `[{X, Y} || X <- Xs, Y <- Ys]` is a nested
  loop; the rightmost generator varies fastest. Later generators can use
  variables from earlier ones: `[{X, Y} || X <- L, Y <- lists:seq(1, X)]`.
- **Filters may call functions.** Unlike guards, a filter is any expression
  that evaluates to `true` or `false`. A filter that returns something else
  raises `bad_filter`.
- **Comprehension variables are local.** Using an already-bound variable in
  a generator pattern makes it a comparison. The compiler now warns, but
  older code may rely on it (rarely) or be buggy (more often).
- **Binary comprehensions** swap the brackets:
  `<< <<F(B)>> || <<B>> <= Bin >>` builds a binary; `[B || <<B>> <= Bin]`
  gives the bytes as a list. Note `<=` instead of `<-`, and the space in
  `<< <<` which keeps the tokenizer from reading `<<<<`. Exercise 10 covers
  the `<<B:8, Rest/binary>>` syntax that these generators use.
- **Map comprehensions** (OTP 26+): `#{K => V || K := V <- Map}`. Exercise 11.
- **`||` is not "or".** Erlang's boolean or is `or` / `orelse`. `||` only
  appears inside comprehensions.

Equivalences that help when mentally translating:

```erlang
[F(X) || X <- L]            %% lists:map(F, L)
[X || X <- L, P(X)]         %% lists:filter(P, L)
[F(X) || X <- L, P(X)]      %% filter then map
[{X, Y} || X <- A, Y <- B]  %% all combinations
```

## Your task

1. Implement the seven functions in `list_comprehensions.erl`, each as a
   single comprehension where possible.
2. Replace each `?TODO` in `list_comprehensions_tests.erl`.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 08_list_comprehensions
```

On Windows (cmd/PowerShell): `erlanglings run 08_list_comprehensions`

## Hints

<details><summary>Hints</summary>

- `squares(N) -> [X * X || X <- lists:seq(1, N)].`
- `pairs(Xs, Ys) -> [{A, B} || A <- Xs, B <- Ys, A < B].`
- `ok_values(Rs) -> [V || {ok, V} <- Rs].`
- `lookup_all(Keys, Pairs) -> [V || K <- Keys, {K2, V} <- Pairs, K =:= K2].`
  Note that `{K, V} <- Pairs` with `K` already bound would compare instead of
  bind, which also works here but earns a compiler warning.
- `bytes_to_hex(Bin) -> lists:flatten([io_lib:format("~2.16.0b", [B]) || <<B>> <= Bin]).`

</details>
