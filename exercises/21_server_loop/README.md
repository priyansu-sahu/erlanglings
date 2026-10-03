# A server loop by hand

Before `gen_server`, every Erlang server was written like this: an API that
sends messages, a loop that receives them, and a pure function that computes
the reply and the next state. `gen_server` is this file with the generic
parts factored out. If you can read this module, you can read any
`gen_server`, because the shape is identical.

## Reading notes

- **Two processes, one module.** The API functions (`put/3`, `get/2`, ...)
  run in the *caller's* process. `init/0`, `loop/1`, `handle_call/2` and
  `handle_cast/2` run in the *server* process. When reading a server module,
  always ask "which process is executing this line?" It determines what
  `self()` is and whose mailbox a `receive` reads.
- **call vs cast.** A *call* sends a request and blocks until the reply
  arrives (with a timeout). A *cast* sends and returns `ok` immediately. Reads
  and anything whose result you need are calls; fire-and-forget notifications
  are casts. The same vocabulary is used by `gen_server:call/2,3` and
  `gen_server:cast/2`.
- **Why `call/2` monitors.** A plain `receive ... after Timeout` would make
  every call to a dead server wait the full timeout. Monitoring the server
  for the duration of the call turns a dead server into an immediate
  `exit({noproc, ...})`. `gen_server:call` does exactly this, which is why
  calling a server that is not running fails instantly with `noproc` while a
  server that is merely slow fails after 5 seconds with `timeout`.
- **The wire format.** `{call, {FromPid, Ref}, Request}` and
  `{cast, Request}`. The `{Pid, Ref}` pair is what gen_server calls `From`;
  you pass it to `gen_server:reply(From, Reply)` when replying later. The real
  tags are `'$gen_call'` and `'$gen_cast'`, which is what you see in crash logs.
- **State threading.** `loop(State)` receives a message, computes `NewState`,
  and tail-calls `loop(NewState)`. There is no mutable variable; the new state
  is simply the argument of the next iteration. In a gen_server the loop is
  hidden and you only write the `handle_*` functions that return the new state.
- **Ordering guarantee.** Messages from one process to another arrive in
  order, so a cast followed by a call from the same client is processed in
  that order. Code often relies on this silently.
- **Unknown messages.** A robust loop has a catch-all clause that ignores
  (or logs) junk and keeps looping. In gen_server that is `handle_info/2`.
- **Stopping.** The loop stops by *not* calling itself again. Here `stop`
  replies `ok` and returns; the process then exits with reason `normal`.
- eunit `{foreach, Setup, Cleanup, [Tests]}` runs the setup and cleanup
  around every test in the list, giving each a fresh server.

## Your task

1. Open `server_loop.erl`. Read the API and the `call/2` / `cast/2` helpers
   (they are given). Implement `loop/1`, `handle_call/2` and `handle_cast/2`.
2. Open `server_loop_tests.erl` and replace every `?TODO` with your prediction.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 21_server_loop
```

On Windows: `erlanglings run 21_server_loop`.

## Hints

<details>
<summary>Hints</summary>

- `loop/1` skeleton:

  ```erlang
  loop(State) ->
      receive
          {call, {From, Ref}, stop} -> From ! {Ref, ok};
          {call, {From, Ref}, Request} ->
              {Reply, NewState} = handle_call(Request, State),
              From ! {Ref, Reply},
              loop(NewState);
          {cast, Request} -> loop(handle_cast(Request, State));
          _Junk -> loop(State)
      end.
  ```

- `handle_call({get, Key}, State)`: `case maps:find(Key, State) of {ok, V} -> {{ok, V}, State}; error -> {{error, not_found}, State} end`.
- `handle_call({incr, Key}, State)`: `New = maps:get(Key, State, 0) + 1, {New, State#{Key => New}}`.
- `handle_cast({delete, Key}, State) -> maps:remove(Key, State).`
- `handle_call({get, k}, #{k => 1})` is `{{ok, 1}, #{k => 1}}`; `handle_call({put, k, 2}, #{})` is `{ok, #{k => 2}}`.
- Each server has its own state: B never saw the put, so `{error, not_found}`.
- `cast/2` always returns `ok`.
- The message is a 3-tuple tagged `call`.

</details>
