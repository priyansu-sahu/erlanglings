# Type specs

`-spec` and `-type` lines are the single most useful thing to read in an
unfamiliar module: they tell you what goes in and what comes out without
reading the body. The runtime ignores them entirely; Dialyzer uses them to
find bugs. This exercise has you implement functions from their specs alone.

## Reading notes

- `-spec name(ArgType1, ArgType2) -> ReturnType.` One spec per function,
  written right above it. `|` means "or", so
  `-> {ok, binary()} | {error, term()}` lists the possible return shapes.
- `-type name() :: definition.` declares a reusable type. Types look like
  function calls: `user_id()`, `status()`. `-export_type([user_id/0])` lets
  other modules refer to it as `type_specs:user_id()`. `-opaque` hides the
  internals: callers may hold the value but not pattern match on it.
- Named-argument form, common in OTP documentation:

  ```erlang
  -spec pick(Key, Opts) -> Value when Key :: atom(), Opts :: [{atom(), term()}], Value :: term().
  ```

- Literals are types: `ok`, `{error, not_found}`, `0`, `1..10`. A union of
  atoms (`online | offline`) is how enums are written.
- Collections: `[T]` or `list(T)` list of T, `[]` empty list, `{a, b}` tuple
  of exactly that shape, `tuple()` any tuple, `#rec{}` a record,
  `#{Key := V}` a map where Key is mandatory, `#{Key => V}` where it is
  optional, `#{atom() => term()}` any atom-keyed map.
- Strings: `string()` is a **charlist** (`[char()]`); `binary()` is a binary;
  `iodata()` is `binary() | iolist()`, i.e. "anything io:put_chars accepts";
  `unicode:chardata()` is the Unicode-aware version. When a spec says
  `string()` and the code passes `<<"...">>`, Dialyzer will complain.
- Numbers: `integer()`, `pos_integer()` (>= 1), `non_neg_integer()` (>= 0),
  `neg_integer()`, `float()`, `number()`, `timeout()` (`non_neg_integer() | infinity`).
- Funs: `fun((A, B) -> C)`, or `fun()` for any fun. `mfa()` is
  `{module(), atom(), arity()}`.
- Record field types: `-record(r, {f :: integer(), g = [] :: [atom()]})`.
- Specs are documentation, not enforcement. A function spec'd to take
  `status()` will happily be called with 42 and crash with `function_clause`
  (or return garbage). Reading a spec tells you the *intended* contract.
- `-dialyzer(...)` attributes and `-spec ... -> no_return().` (a function
  that always raises or loops) are the other spec-adjacent things you will see.

## Your task

1. Open `type_specs.erl`. Each function has a spec and a one-line comment.
   Implement every function so it satisfies its spec and the tests.
2. Open `type_specs_tests.erl` and replace every `?TODO` with your prediction.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

Optional: if you have Dialyzer handy, run it on your solution:
`dialyzer --src exercises/17_type_specs/type_specs.erl`.

## Run

```sh
./erlanglings run 17_type_specs
```

On Windows: `erlanglings run 17_type_specs`.

## Hints

<details>
<summary>Hints</summary>

- `describe({away, Reason}) -> <<"away: ", Reason/binary>>.`
- `find`: `lists:keyfind(UserId, #presence.user_id, Presences)` returns the record or `false`.
- `online_ids(Ps) -> [Id || #presence{user_id = Id, status = online} <- Ps].`
- `parse_status(<<"away:", Reason/binary>>) -> {ok, {away, Reason}};` then a catch-all clause.
- `summarize`: fold or three list comprehensions with `length/1`.
- `pick(Key, Opts) -> proplists:get_value(Key, Opts).` The default default is `undefined`.
- `ensure_binary(B) when is_binary(B) -> B; ensure_binary(A) when is_atom(A) -> atom_to_binary(A); ensure_binary(IoData) -> iolist_to_binary(IoData).`
- Calling `describe(42)` matches no clause: `error:function_clause`.

</details>
