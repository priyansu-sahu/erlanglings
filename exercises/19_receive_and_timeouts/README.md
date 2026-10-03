# receive, timeouts, and selective receive

A `receive` without a timeout waits forever, which is almost never what
production code wants. This exercise covers `after`, the `make_ref()` trick
that lets a process tell replies apart, and how messages that don't match
stay quietly in the mailbox.

## Reading notes

- Shape: `receive Pattern -> Body; ... after Ms -> TimeoutBody end`. `Ms` is
  milliseconds or `infinity`. The after body's value becomes the value of the
  whole receive.
- `after 0` means "look once, don't wait". Draining a mailbox is a loop of
  `receive M -> [M | drain()] after 0 -> [] end`. You will also see it used
  to throw away stale replies before a new call.
- `receive after Ms -> ok end` with no patterns at all is a sleep.
- **Selective receive**: only a matching message is removed. Everything else
  stays, in order. This is powerful (wait for exactly your reply) and
  dangerous (a mailbox that fills with unmatched messages is a classic
  production memory leak; each receive then scans the whole backlog).
- **The reference trick.** `Ref = make_ref()` makes a globally unique value.
  Tagging a request with it and receiving `{Ref, Reply}` guarantees you get
  the reply to *this* request, not a late reply to a previous one. This is the
  core of `gen_server:call`; the wire format is
  `{'$gen_call', {FromPid, Ref}, Request}` and the reply is `{Ref, Reply}`.
  Modern OTP uses an *alias* (a special reference) so late replies are dropped
  automatically.
- Timeouts show up as `exit({timeout, {gen_server, call, [...]}})` in logs: a
  `gen_server:call` that waited the default 5000 ms without a reply.
- eunit fixtures: `name_test_()` (note the trailing underscore) returns a
  *test description* rather than running a test. `{setup, Start, Stop,
  Instantiator}` runs Start once, passes its result to the instantiator, which
  returns a list of `?_assert*` tests (also with an underscore), then runs Stop.
  You will meet this shape in nearly every eunit file that touches processes.

## Your task

1. Open `receive_and_timeouts.erl`. Read `server_loop/0` (it is given). Then
   implement `rpc/3`, `flush/0`, and `wait_for/2`.
2. Open `receive_and_timeouts_tests.erl` and replace every `?TODO` with your
   prediction. Notice the `{setup, ...}` fixture while you are there.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 19_receive_and_timeouts
```

On Windows: `erlanglings run 19_receive_and_timeouts`.

## Hints

<details>
<summary>Hints</summary>

- `rpc`: `Ref = make_ref(), Pid ! {call, self(), Ref, Request}, receive {Ref, Reply} -> Reply after Timeout -> {error, timeout} end.`
- `flush() -> receive M -> [M | flush()] after 0 -> [] end.`
- `wait_for(Tag, T) -> receive {Tag, V} -> {ok, V} after T -> {error, timeout} end.`
  Because the pattern names `Tag`, only messages with that tag are taken.
- `after 0` on an empty mailbox gives the after value: `nothing`.
- Waiting for `b` when only `a` is present times out, and `a` remains: `flush()` is `[a]`.
- Two fresh references are never equal.
- After receiving `{NewRef, fresh}`, one message (`{OldRef, stale}`) is left.

</details>
