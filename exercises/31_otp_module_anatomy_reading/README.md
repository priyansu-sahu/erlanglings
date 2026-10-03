# Anatomy of an OTP module (capstone reading)

`session_registry.erl` is the kind of module you will open on your first
week: a gen_server that owns an ETS table, monitors other processes, uses
records, specs, macros and the logger, and exposes a small API that the rest
of the system calls. Nothing in it is exotic, and that is the point. If you
can read this module comfortably, you can read most of a production Erlang
codebase.

You do not change it. Read it, then answer the questions in
`session_registry_tests.erl`.

## Reading notes

### How to read a module like this in five minutes

1. **Header comment (30 seconds).** The `@doc` block tells you the purpose
   and the two design decisions that matter: one writer (the server) and
   lock-free readers (ETS). Everything else follows from those.

2. **The exports (30 seconds).** The first `-export` is the public API. Eight
   functions: start/stop, two writes (`register`, `unregister`), three reads
   (`lookup`, `devices`, `count`), one fan-out (`broadcast`). The second
   `-export` is the gen_server callbacks, and you already know their shapes.
   You now know everything the module can do without reading a line of
   logic.

3. **Macros and types (30 seconds).** `-define(TABLE, ?MODULE)` means the
   ETS table is named after the module. `?MAX_DEVICES_PER_USER` is a limit;
   expect a `{error, too_many_...}` somewhere. The `-type` lines tell you
   ids are binaries.

4. **The records (1 minute).** This is the most important minute.
   * `#session{}` is a *row*: the key is a `{UserId, DeviceId}` pair, plus
     the pid, a monitor ref, and a timestamp. The key being a tuple tells
     you the table is a `set` with composite keys, not a `bag`.
   * `#state{}` is the *server's memory*: the table id and a reverse index
     from monitor ref to key. Whenever a record holds a map keyed by
     references, there is a `'DOWN'` handler somewhere that uses it.

5. **The API functions (1 minute).** Classify each one:
   * `register/2` -> `gen_server:call` (synchronous; needs an answer).
     Note that it passes `self()`: the *caller* becomes the session.
   * `unregister/2` -> `gen_server:cast` (fire and forget).
   * `lookup/1`, `devices/1`, `count/0` -> **touch ETS directly**. No
     message to the server. This is why the table is `protected` (anyone
     may read) and why reads scale.
   * `broadcast/2` -> plain `!` to each session pid.

6. **The callbacks (1.5 minutes).** Jump from each API call to its clause.
   * `init/1`: creates the table. `{keypos, #session.key}` because element 1
     of a record is its name. The server owns the table, so the table lives
     exactly as long as the server.
   * `handle_call({register, ...})`: remove any old row for this device,
     check the limit, monitor the pid, insert the row, update the reverse
     index. Reply `ok`.
   * `handle_cast({unregister, ...})`: delegate to `remove_session/2`.
   * `handle_info({'DOWN', MRef, ...})`: the monitored process died; use the
     reverse index to find the key, delete the row. The `error` branch
     handles a `'DOWN'` for something already unregistered.
   * Each callback ends with a catch-all that logs with `?LOG_WARNING` and
     carries on. The server never crashes on bad input.

7. **Internal functions (30 seconds).** `remove_session/2` is the single
   place that knows how to fully undo a registration: demonitor (with
   `[flush]` so a queued `'DOWN'` is discarded), delete the row, forget the
   ref. When one helper does the undo, the module stays consistent.

### Things worth noticing

* `#session{key = {UserId, '$1'}, pid = '$2', _ = '_'}` is a match-spec
  head written with record syntax; `_ = '_'` sets every other field to the
  wildcard. This is how you query an ETS table of records.
* `State0`, `State1`: numbered variables show the state being threaded
  through a sequence of pure updates, because variables cannot be rebound.
* `maps:take/2` returns `{Value, MapWithout}` or `error`; it is a lookup and
  a delete in one.
* `erlang:monitor/2` plus a `'DOWN'` clause is the standard way to be told
  that another process died without being linked to it. Linking would take
  the registry down with the session.
* `-include_lib("kernel/include/logger.hrl")` brings in the `?LOG_*`
  macros; they add module, line and pid metadata automatically.
* `true = ets:insert(...)`, `true = erlang:demonitor(...)`: matching on
  `true` turns an unexpected return into an immediate crash with a clear
  `badmatch`. You will see `ok = ...` used the same way everywhere.

### What is *not* in this module

Notice what the module does not do: it never sends anything to the session
processes except in `broadcast/2`, it never kills them, and it has no
timers. Knowing what a module does not do is as useful as knowing what it
does when you are hunting a bug.

## Your task

Read `session_registry.erl` using the walkthrough above. Then open
`session_registry_tests.erl` and replace every `?TODO`. The test file
contains small fake "session" processes; read those helpers too, they are
only a few lines.

## Run

```sh
./erlanglings run 31_otp_module_anatomy_reading
```

On Windows: `erlanglings run 31_otp_module_anatomy_reading`.

## Hints

<details><summary>Hints</summary>

* Q2: `lookup/1` returns `[{DeviceId, Pid}]`, and the pid is the test
  process itself: `[{<<"phone">>, Me}]`.
* Q3: `lists:sort` on `{Device, Pid}` tuples sorts by device name first, so
  `laptop` comes before `phone`.
* Q4: `remove_session` runs before the insert, so only the new pid remains
  and `count/0` is still 1.
* Q5: `[ok, ok, ok, ok, {error, too_many_devices}]` and a count of 4.
* Q7: the registry never kills a process: `true`, and the row is gone: `0`.
* Q8: `broadcast/2` returns `length(Sessions)`, so `2` and `0`; each
  session received `{session_msg, ping}` and forwarded `ping`.
* Q10: `#session.key` is position 2; `protected`; and the owner is the
  registry process, so `true`.
* Q11: `undefined`.

</details>
