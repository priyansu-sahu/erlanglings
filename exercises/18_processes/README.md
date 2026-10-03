# Processes

Everything interesting in an Erlang system is a process: every connection,
every session, every timer. Processes share nothing and communicate only by
sending messages. The three primitives (`spawn`, `!`, `receive`) are the
foundation that `gen_server` and friends are built on, so you need to read
them fluently before OTP makes sense.

## Reading notes

- `spawn(fun() -> ... end)` or `spawn(Mod, Fun, Args)` starts a process and
  returns its pid immediately. The `Mod, Fun, Args` form requires the function
  to be exported, which is why you see "internal" loop functions in export
  lists with a comment next to them. `spawn_link` and `spawn_monitor` are
  the same plus a link/monitor (exercise 20).
- `Pid ! Msg` sends asynchronously. It never blocks, never fails (even if the
  pid is dead), and returns `Msg`, so `Pid ! {self(), Req}` on its own line is
  the whole send.
- `receive Pattern -> Body; ... end` blocks until a message **matching one of
  the patterns** arrives. Non-matching messages stay in the mailbox in order.
  This selective receive is how a caller can wait for exactly its reply and
  ignore everything else. `receive ... after Ms -> ... end` adds a timeout
  (exercise 19).
- Guaranteed ordering is between one sender and one receiver only. Messages
  from two different processes can interleave in any order.
- `self()` is the current pid. The request/reply idiom embeds it in the message
  so the server knows who to answer: `Pid ! {self(), Req}, receive {Pid, Reply} -> Reply end`.
- A server is a function that receives, acts, and calls itself. Because the
  recursive call is in tail position it does not grow the stack. The process
  dies quietly when the function finally returns.
- Pids print as `<0.123.0>`. Comparing a pid to `self()` is a common guard:
  `when Pid =:= self()`.
- A pattern you will meet in parallel code: spawn one worker per item, then
  collect replies **in a known order** by matching on each worker's pid.

## Your task

1. Open `processes.erl` and implement the echo server (`start_echo/0`,
   `echo_loop/0`, `echo/2`, `stop/1`) and `parallel_map/2`.
2. Open `processes_tests.erl` and replace every `?TODO` with your prediction.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 18_processes
```

On Windows: `erlanglings run 18_processes`.

## Hints

<details>
<summary>Hints</summary>

- `start_echo() -> spawn(?MODULE, echo_loop, []).`
- `echo_loop() -> receive {From, Msg} -> From ! {self(), Msg}, echo_loop(); stop -> ok end.`
- `echo(Pid, Msg) -> Pid ! {self(), Msg}, receive {Pid, Reply} -> Reply end.`
- `parallel_map`: `Parent = self(), Pids = [spawn(fun() -> Parent ! {self(), F(X)} end) || X <- List], [receive {Pid, R} -> R end || Pid <- Pids].`
- `!` returns its right-hand side, the message.
- Mailbox order from a single sender is preserved: `[first, second, third]`.
- After receiving `b`, the only message left is `a`.
- Sending to a dead pid is a no-op that still returns the message.

</details>
