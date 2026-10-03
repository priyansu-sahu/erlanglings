# Maps

Maps are the key-value type you will see most in modern Erlang: process
state, configuration, decoded JSON, options passed to functions. The syntax
has two arrows (`=>` and `:=`) with different meanings, and that is the main
thing to get straight.

## Reading notes

```erlang
State0 = #{count => 0, name => <<"wa">>},   % build
State1 = State0#{count => 1},               % insert-or-update
State2 = State1#{count := 2},               % update; badkey if absent
#{count := N} = State2,                     % match; := only, extra keys ok
```

- **`=>` puts, `:=` requires.** In construction and update, `=>` works for
  any key while `:=` insists the key already exist. In patterns only `:=` is
  legal. Authors use `:=` in updates on purpose: it turns a typo in a key
  name into a crash instead of a silently growing map.
- **A map pattern is a subset check.** `#{a := A}` matches any map that has
  key `a`, no matter what else is in it. `#{}` matches *every* map. When you
  read `handle(#{type := Type} = Msg)`, the function accepts any map with a
  `type` key and keeps the whole thing as `Msg`.
- **Atom keys vs binary keys.** `#{user_id => 7}` is internal state built by
  this codebase. `#{<<"user_id">> => 7}` is almost certainly decoded JSON or
  other external data. Conversions between the two are a common source of
  "key not found" bugs.
- **Lookups and their failure shapes.** `maps:get/2` raises `{badkey, K}`;
  `maps:get/3` returns the default; `maps:find/2` returns `{ok, V} | error`;
  `maps:is_key/2` is a boolean. `map_get/2` and `is_map_key/2` are
  guard-safe versions.
- **`maps:merge(A, B)`**: B wins. "Defaults then overrides" is
  `maps:merge(Defaults, Given)`.
- **`maps:fold(F, Acc, M)`** calls `F(Key, Value, Acc)`, three arguments,
  unlike `lists:foldl`.
- **Map comprehensions** (OTP 26+): `#{K => F(V) || K := V <- M}`. Note the
  `:=` in the generator.
- **Order is not insertion order.** Small maps (32 keys or fewer) iterate in
  key order; large maps are hash-ordered. Code that depends on order is wrong
  even if it happens to work.
- **Keys use exact equality.** `1` and `1.0` are different keys.
- **Maps vs records.** Records (next exercise) are compile-time tuples with
  fixed fields; maps are dynamic. OTP code and older codebases lean on
  records for process state; newer code often uses maps. You will read both.

## Your task

1. Implement the nine functions in `map_basics.erl`.
2. Replace each `?TODO` in `map_basics_tests.erl`.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 11_map_basics
```

On Windows (cmd/PowerShell): `erlanglings run 11_map_basics`

## Hints

<details><summary>Hints</summary>

- `get_age(#{age := Age}) -> Age.`
- `birthday(#{age := Age} = User) -> User#{age := Age + 1}.`
- `has_email(User) -> maps:is_key(email, User).`
- `merge_defaults(Config, Defaults) -> maps:merge(Defaults, Config).`
- `to_pairs(M) -> lists:sort(maps:to_list(M)).`
- `count_words/1`:
  ```erlang
  lists:foldl(fun(W, Acc) -> maps:update_with(W, fun(N) -> N + 1 end, 1, Acc) end,
              #{}, Words)
  ```
- `invert(M) -> #{V => K || K := V <- M}.`

</details>
