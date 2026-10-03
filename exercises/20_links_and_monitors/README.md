# Links and monitors

"Let it crash" only works because something notices the crash. Links and
monitors are the two mechanisms. Every supervisor, every `gen_server:call`,
and most "clean up when the client disconnects" code is built on them, so
`{'EXIT', Pid, Reason}` and `{'DOWN', Ref, process, Pid, Reason}` are
messages you must recognize instantly.

## Reading notes

- **Link** (`link/1`, `spawn_link/1,3`): bidirectional. If one side exits
  with a reason other than `normal`, the other side is killed with the same
  reason. Unless it **traps exits** (`process_flag(trap_exit, true)`), in which
  case it receives `{'EXIT', Pid, Reason}` as a normal message instead. A
  supervisor is a process that traps exits and restarts whatever sent them.
- **Monitor** (`monitor(process, Pid)`, `spawn_monitor/1`): one-way. The
  watcher gets exactly one `{'DOWN', Ref, process, Pid, Reason}` when the
  target dies, and is never affected itself. `demonitor(Ref, [flush])` cancels
  and removes any already-queued `'DOWN'`. Monitoring a dead pid yields an
  immediate `'DOWN'` with reason `noproc`.
- **Exit reasons** to recognize in logs and `'DOWN'` messages:
  - `normal`: the process function returned. Does not propagate over links.
  - `shutdown` / `{shutdown, Term}`: stopped on purpose by a supervisor. No
    crash report.
  - `killed`: someone called `exit(Pid, kill)`. `kill` cannot be trapped and
    is reported as `killed`.
  - `noproc`: you monitored or called something that was already gone.
  - Anything else is a crash, usually `{ErrorReason, Stacktrace}` such as
    `{{badmatch, 2}, [...]}` or `{badarith, [...]}`.
- `exit/1` raises an `exit`-class exception in the current process (catchable
  with `try ... catch exit:R`). `exit/2` sends an exit *signal* to another
  process. Same name, different beast.
- `gen_server:call` monitors the server while waiting, which is why a dead
  server produces `exit({noproc, ...})` or `exit({Reason, ...})` immediately
  rather than a 5-second timeout.
- Pattern you will see in connection handlers: `monitor(process, ClientPid)`
  at registration, then a `handle_info({'DOWN', _, process, Pid, _}, State)`
  clause that removes `Pid` from the state.

## Your task

1. Open `links_and_monitors.erl` and implement the three functions.
2. Open `links_and_monitors_tests.erl` and replace every `?TODO` with your
   prediction.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

You will see crash reports printed while the tests run (lines starting with
`=ERROR REPORT====` or `Error in process`). That is expected: processes are
crashing on purpose, and the runtime logs it.

## Run

```sh
./erlanglings run 20_links_and_monitors
```

On Windows: `erlanglings run 20_links_and_monitors`.

## Hints

<details>
<summary>Hints</summary>

- `run_and_wait`: `{Pid, Ref} = spawn_monitor(Fun), receive {'DOWN', Ref, process, Pid, normal} -> {ok, normal}; {'DOWN', Ref, process, Pid, Reason} -> {crashed, Reason} end.`
- `exit_reason_via_link`: `Old = process_flag(trap_exit, true), Pid = spawn_link(Fun), receive {'EXIT', Pid, Reason} -> process_flag(trap_exit, Old), Reason end.`
- `supervise_once`: call `run_and_wait/1` twice at most and translate the results.
- Brutal kill shows up as `killed`, not `kill`.
- An already-dead target gives `noproc`.
- The trapped message is `{'EXIT', Pid, oops}`.
- `exit/1` is class `exit`.
- After `demonitor(Ref, [flush])` the mailbox is empty: `0`.

</details>
