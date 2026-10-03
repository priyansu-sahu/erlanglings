# gen_server basics

`gen_server` is the single most common thing you will read in an Erlang
codebase. It is a *behaviour*: OTP provides the generic process loop (receive,
dispatch, reply, crash handling) and your module provides *callbacks* that
fill in the application-specific parts.

## Reading notes

Every gen_server module has the same two halves, and you read them as a pair:

```
API (runs in the caller)                 Callback (runs in the server)
----------------------------------       ---------------------------------------------
put(K, V) ->                             handle_call({put, K, V}, _From, State) ->
    gen_server:call(?MODULE, {put,K,V}).     {reply, ok, State#{K => V}};
delete(K) ->                             handle_cast({delete, K}, State) ->
    gen_server:cast(?MODULE, {delete,K}).    {noreply, maps:remove(K, State)};
```

The call flow for a synchronous request is:

```
caller: kv_store:put(k, v)
  -> gen_server:call(kv_store, {put, k, v})      % sends a message, blocks
     -> [server process] handle_call({put, k, v}, From, State)
        -> returns {reply, ok, NewState}
  <- gen_server:call returns `ok` to the caller
```

Things to notice while reading:

* **`-behaviour(gen_server).`** tells you which callbacks to expect. The
  compiler warns if one is missing.
* **Two `-export` lists.** Production code almost always separates the public
  API exports from the callback exports, often under `%%% API` and
  `%%% gen_server callbacks` banners. The callbacks are exported only because
  OTP must be able to call them; nobody else should.
* **`?MODULE`** as the server name. `gen_server:call(?MODULE, ...)` means
  "call the process registered under this module's name". That only works for
  singletons started with `{local, ?MODULE}`; servers with many instances pass
  a pid instead.
* **`call` vs `cast`.** `call` blocks for a reply (default 5 s timeout, then the
  caller crashes with `{timeout, ...}`). `cast` returns `ok` immediately. When
  reading, `cast` usually means "the caller does not care about the result".
* **Message ordering.** Erlang guarantees that messages between a pair of
  processes arrive in the order sent. That is why a `cast` followed by a
  `call` from the same process is safe: the cast is always handled first.
* **The catch-all clause.** `handle_call(Request, _From, State) -> {reply,
  {error, ...}, State}` at the bottom is a defensive habit; without it an
  unknown request crashes the server with `function_clause`.
* **`handle_info`** is the dumping ground for everything that is not a call or
  cast: timers (`erlang:send_after`), monitor `'DOWN'` messages, port data,
  and plain `Pid ! Msg` sends.
* **`terminate/2` and `code_change/3`** are nearly always boilerplate. Skim
  them; they matter only when the server owns external resources.

## Your task

Open `kv_store.erl`. The API and the skeleton are written. Implement:

1. `handle_call/3` clauses for `{put, Key, Value}`, `{get, Key}` and `size`.
2. A `handle_cast/2` clause for `{delete, Key}`.

Keep the catch-all clauses at the bottom of both functions.

## Run

```sh
./erlanglings run 23_gen_server_basics
```

On Windows: `erlanglings run 23_gen_server_basics`.

## Hints

<details><summary>Hints</summary>

* The state is a map. `State#{Key => Value}` adds or replaces a key.
* `maps:find(Key, State)` returns `{ok, Value}` or the bare atom `error`, so a
  `case` with those two clauses gives you the `{ok, V} | {error, not_found}`
  reply directly.
* `maps:size/1` and `maps:remove/2` do the rest.
* Clause order matters: the catch-all `handle_call(Request, _From, State)`
  must stay LAST, otherwise it swallows every request.

</details>
