# ETS

ETS (Erlang Term Storage) is the built-in, in-memory, concurrent key/value
table. In a large Erlang system you will find it everywhere: session
registries, caches, counters, routing tables, rate-limit buckets. Reading
ETS code fluently means knowing its handful of quirks by heart.

## Reading notes

### Creating and owning a table

```erlang
Tab = ets:new(my_sessions, [set, public, named_table, {read_concurrency, true}]).
```

* The table is **owned by the process that calls `ets:new`** and is deleted
  when that process dies. So look for `ets:new` in a gen_server's `init/1`
  (or in a dedicated "table owner" process under a supervisor). A table
  created inside a short-lived process is a bug waiting to happen.
* `named_table` means you can use the atom `my_sessions` everywhere instead
  of the returned table id. Most production tables are named, which is why
  you see `ets:lookup(my_sessions, Key)` with no table variable in sight.
* Access: `protected` (default: owner writes, everyone reads), `public`
  (anyone writes), `private`.
* Type: `set` (one row per key), `ordered_set` (sorted by key; the only type
  with a defined iteration order), `bag` (many rows per key),
  `duplicate_bag`.
* `{keypos, N}`: which tuple element is the key. Default 1. Code storing
  records uses `{keypos, #session.id}` because element 1 of a record is the
  record name.

### The quirks

| what you read | what it means |
|---|---|
| `[] = ets:lookup(T, K)` | **lookup always returns a list**, even for a set. Missing key is `[]`, not an error. |
| `[{K, V}] = ets:lookup(T, K)` | the common "I know there is exactly one row" pattern (crashes with `badmatch` if there is none) |
| `ets:insert(T, Row)` returns `true` | for a `set` it overwrites silently |
| `ets:insert_new/2` | returns `false` instead of overwriting; used for "claim this key" |
| `ets:update_counter(T, K, 1, {K, 0})` | atomic increment with a default row for a missing key |
| `ets:match(T, {'$1', '_'})` | returns `[[Val1], [Val2], ...]`: each row's variables wrapped in a list |
| `ets:select(T, MatchSpec)` | the general query; see below |
| `ets:tab2list(T)` | all rows; order is undefined except for `ordered_set` |
| `ets:info(T, size)` | row count; `ets:info(T)` is `undefined` for a deleted table |
| `ets:foldl/3` | fold over all rows (no ordering guarantee) |

### Match specifications

Match specs are the little query language used by `ets:select`, `dbg`,
`recon` and tracing. They look alien the first time:

```erlang
[{ {'$1', '$2'},            % MatchHead: a row pattern. '$N' binds, '_' ignores
   [{'<', '$2', Cutoff}],   % Guards: list of conditions, written prefix-style as tuples
   ['$1'] }]                % Body: what to return for each matching row
```

Read it as: "for every row `{Id, Ts}` where `Ts < Cutoff`, return `Id`".
A few more things you will see in the body: `'$_'` means the whole row,
`'$$'` means all bound variables as a list, and a literal tuple must be
doubled, `{{'$2', '$1'}}`, because a single-braced tuple would be read as a
function call.

When a match spec gets hairy, `ets:fun2ms(fun({Id, Ts}) when Ts < Cutoff ->
Id end)` (with `-include_lib("stdlib/include/ms_transform.hrl")`) generates
it from a fun. Many codebases use that form instead.

## Your task

1. In `ets_store.erl`, implement `put/3`, `get/2`, `incr/2`, `keys/1`,
   `delete/2` and `older_than/2` (the last one with a match spec).
2. In `ets_store_tests.erl`, answer the reading questions by replacing each
   `?TODO`.

Note: the module is called `ets_store` because `ets` is the standard library
module.

## Run

```sh
./erlanglings run 27_ets
```

On Windows: `erlanglings run 27_ets`.

## Hints

<details><summary>Hints</summary>

* `put/3`: `ets:insert(Tab, {Key, Value})` returns `true`; return `ok`.
* `get/2`: `case ets:lookup(Tab, Key) of [{_, V}] -> {ok, V}; [] -> not_found end`.
* `incr/2`: `ets:update_counter(Tab, Key, 1, {Key, 0})` returns the new value.
* `keys/1`: `ets:select(Tab, [{{'$1', '_'}, [], ['$1']}])`, then `lists:sort`.
* Q4: `[[a], [b]]`. Q5: the body `{{'$2', '$1'}}` builds `{Value, Key}`
  tuples, and the guard keeps only rows with a value greater than 1.
* Q7: `ets:info/1` of a table that no longer exists is `undefined`.
* Q8: with `named_table`, `ets:new/2` returns the name atom itself.

</details>
