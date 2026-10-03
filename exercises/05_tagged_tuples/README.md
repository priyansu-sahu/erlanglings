# Tagged Tuples

Erlang signals success and failure with plain data: `{ok, Value}`,
`{error, Reason}`, bare `ok`. There is no `Result` type and no checked
exception. The convention is so uniform that once you know it, you can
predict the return shape of most library functions without reading their docs.

## Reading notes

What the tags mean:

| Shape                   | Meaning                                        |
|-------------------------|------------------------------------------------|
| `ok`                    | succeeded, nothing to return                   |
| `{ok, V}`               | succeeded with a payload                       |
| `{ok, A, B}`            | succeeded with two payloads (flat, not nested) |
| `{error, Reason}`       | failed; `Reason` is an atom or small term      |
| `error` / `false` / `undefined` | "not found" from lookup-style functions |
| `{reply, R, State}`, `{noreply, State}`, `{stop, Reason, State}` | gen_server callback results (exercise 20) |

How callers consume them:

```erlang
%% 1. Branch on the outcome
case lookup(Key, Table) of
    {ok, Value}      -> use(Value);
    error            -> default()
end

%% 2. Assert the happy path; anything else crashes with badmatch
{ok, Pid} = my_sup:start_child(Spec)

%% 3. Keep the whole error and pass it up unchanged
case do_thing() of
    {ok, _} = Ok      -> Ok;
    {error, _} = Err  -> Err
end
```

Pattern 3 uses the alias form `Pattern = Var`. Read `{error, _} = Err` as
"this must be an error tuple, and call the whole thing `Err`".

Gotchas:

- **Each library picks its own "not found".** `maps:find/2` gives `error`,
  `lists:keyfind/3` gives `false`, `proplists:get_value/2` gives `undefined`,
  `maps:get/3` gives whatever default you pass. Matching `{ok, V}` against a
  `false` is a silent fall-through to the wrong clause.
- **`{ok, Pid, Ref}` vs `{ok, {Pid, Ref}}`.** Both exist in the wild. Count
  the braces.
- **Reasons are terms, not strings.** `{error, enoent}`, `{error, {badrpc,
  nodedown}}`, `{error, {already_started, Pid}}`. Crash logs print them as
  terms, so learning to read nested tuples is learning to read logs.
- **Specs tell you the shapes.** From exercise 05 on, every exported function
  has a `-spec`. A spec like
  `-spec lookup(term(), [{term(), term()}]) -> {ok, term()} | error.`
  lists every return shape after the arrow, separated by `|`. When reading
  an unfamiliar module, read the specs first.

## Your task

1. Implement the five functions in `tagged_tuples.erl`.
2. Replace each `?TODO` in `tagged_tuples_tests.erl` with your prediction.
   The "not found conventions" test is worth getting right from memory.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 05_tagged_tuples
```

On Windows (cmd/PowerShell): `erlanglings run 05_tagged_tuples`

## Hints

<details><summary>Hints</summary>

- `parse_age/1`: `case string:to_integer(Input) of {N, []} when N < 0 -> ...; {N, []} -> ...; _ -> ... end`.
- `unwrap/1`: two clauses; the error clause calls `erlang:error(Reason)`.
- `lookup/2`: `case lists:keyfind(Key, 1, Pairs) of {Key, V} -> {ok, V}; false -> error end`.
- `all_ok/1`: write a helper `all_ok([], Acc) -> {ok, lists:reverse(Acc)};`
  with clauses for `[{ok, V} | Rest]` and `[{error, _} = Err | _]`.
- The badmatch reason is `{badmatch, TheValueThatDidNotMatch}`.

</details>
