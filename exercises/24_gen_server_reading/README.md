# Reading a gen_server

This is the first *reading* exercise. `rate_limiter.erl` is a complete,
production-style gen_server. You do not change it. Your job is to read it and
predict how it behaves; the predictions go in `rate_limiter_tests.erl`.

This is the skill that matters most when you join a large Erlang codebase:
open an unfamiliar server module and, in a few minutes, be able to say what
it does, who talks to it, and what happens when it receives X.

## Reading notes

A repeatable way to read any gen_server:

1. **Header comment and `-module`.** What is this thing, in one sentence?
2. **The two `-export` lists.** The first is the API: this is the server's
   entire public surface. The second is the callbacks; you already know
   their shapes.
3. **`-record(state, ...)`.** The state record is the server's memory. Read
   every field and its type; most of the logic is about mutating these fields.
   Typed fields (`limit :: pos_integer()`) are documentation.
4. **`init/1`.** How is the initial state built? What options are read, with
   what defaults (`maps:get(Key, Opts, Default)`)? Does it start timers,
   open tables, monitor things?
5. **For each API function, jump to its callback clause.** The request term
   the API builds (`{allow, Key}`) is what you grep for in `handle_call`.
   Note whether the API uses `call` (synchronous, has a reply) or `cast`
   (asynchronous, no reply).
6. **`handle_info`.** Anything here reveals the server's *asynchronous*
   inputs: timers, monitors, raw messages. Here it is the `refill` timer.
7. **`terminate/2`.** What is cleaned up? That tells you what resources the
   server owns.
8. **Internal functions** at the bottom. Usually small helpers; read them
   when a callback calls them.

Things to notice in this particular module:

* `start_link/1` uses `gen_server:start_link(?MODULE, Opts, [])` with no
  `{local, Name}`. The server is **anonymous**: you can run many instances,
  and clients must hold the pid. Compare with `kv_store` in exercise 23.
* `#state{buckets = Buckets} = State` in a function head binds *both* the
  whole record (`State`) and one field (`Buckets`). Very common pattern.
* `State#state{buckets = NewBuckets}` returns a **copy** of the record with
  one field changed. Nothing is mutated in place.
* `erlang:send_after(Ms, self(), Msg)` delivers `Msg` to the server's own
  mailbox later. Because it is a plain message, it lands in `handle_info`.
* `maps:get(Key, Map, Default)` is the three-argument form: no crash on a
  missing key.
* The `_ = erlang:cancel_timer(Timer)` idiom: the return value is
  deliberately ignored. `_ =` tells the reader (and the linter) "I know this
  returns something; I do not care".
* `sys:get_state(Pid)` (used in the tests) lets you inspect a live server's
  state from the shell. Combine it with `rr(rate_limiter)` in the shell to
  see record field names instead of a bare tuple.

The call flow for `allow/2`:

```
client: rate_limiter:allow(Pid, alice)
  -> gen_server:call(Pid, {allow, alice})
     -> handle_call({allow, alice}, From, State)
        -> tokens_left(alice, State)              % maps:get(alice, Buckets, Limit)
        -> {reply, ok, State#state{buckets = ...}}
  <- ok
```

## Your task

Read `rate_limiter.erl`. Then open `rate_limiter_tests.erl` and replace every
`?TODO` with the value you expect. Each question says which part of the
module to look at. Do not edit `rate_limiter.erl`.

If a prediction is wrong, do not just paste the actual value in: go back to
the code and find the line that explains the difference.

## Run

```sh
./erlanglings run 24_gen_server_reading
```

On Windows: `erlanglings run 24_gen_server_reading`.

## Hints

<details><summary>Hints</summary>

* Q1: `tokens_left/2` falls back to `Limit` when the key is absent from
  `buckets`. The test starts the server with `limit => 3`.
* Q2: when `tokens_left` returns `0`, the first `case` clause replies
  `{error, rate_limited}` and leaves the state untouched.
* Q4: the last `handle_call` clause matches anything.
* Q5: `gen_server:cast/2` always returns `ok`. Messages from one process to
  another are delivered in order, so the `reset` cast is handled before the
  `remaining` call that follows it.
* Q6: `handle_info(refill, ...)` replaces `buckets` with an empty map and
  re-arms the timer.
* Q7: the catch-all `handle_info(_Info, State)` clause ignores the message.
* Q8: a record with 4 fields is a 5-tuple whose first element is the record
  name.

</details>
