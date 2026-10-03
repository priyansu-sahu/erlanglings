# Registered processes

Long-lived servers are reached by *name*, not by pid. `register/2`,
`whereis/1` and `Name ! Msg` are the raw tools; `{local, ?MODULE}` in a
`gen_server:start_link` call is the same thing dressed up. Half the modules
in a production system register themselves, so `?MODULE` doubles as "this
code" and "this process".

## Reading notes

- `register(Name, Pid)` binds an atom to a pid, node-locally. One name per
  pid, one pid per name; a second `register` with a taken name raises
  `error:badarg`. `register/2` returns `true`.
- `whereis(Name)` returns the pid or `undefined`. Checking
  `whereis(?MODULE) =:= undefined` before starting is a common (racy)
  "already started?" guard; supervisors make it unnecessary.
- `Name ! Msg` sends to the registered process. If no process has the name
  it raises `error:badarg`. Contrast with `Pid ! Msg` to a dead pid, which
  silently succeeds. `erlang:send(Name, Msg)` is the same thing as a function.
- Names are released automatically when the process dies, so a restarted
  server can re-register under the same name. This is what makes "restart
  and clients reconnect by name" work.
- `registered()` lists every registered name on the node. In the shell it is
  a quick way to see which servers are up; you will also find OTP's own
  (`code_server`, `application_controller`, `kernel_sup`, `error_logger`, ...).
- Name scopes in OTP APIs: `{local, Name}` (this node), `{global, Name}`
  (cluster-wide via the `global` module), `{via, Module, Name}` (a pluggable
  registry such as `gproc` or `pg`). When you read
  `gen_server:call({global, Name}, Req)` the request may cross nodes.
- A registered process is a per-node singleton. When a module is a hot spot,
  production code either shards (several registered names like `worker_1`,
  `worker_2`, picked with `erlang:phash2`) or keeps the registered process as
  a manager that hands out pids of pooled workers.

## Your task

1. Open `registered_processes.erl` and implement the counter: `start/0`
   (register under `?MODULE`), `stop/0`, `increment/0`, `value/0`, `reset/0`,
   and `loop/1`.
2. Open `registered_processes_tests.erl` and replace every `?TODO` with your
   prediction.
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 22_registered_processes
```

On Windows: `erlanglings run 22_registered_processes`.

## Hints

<details>
<summary>Hints</summary>

- `start()`: `case whereis(?MODULE) of undefined -> Pid = spawn(?MODULE, loop, [0]), register(?MODULE, Pid), Pid; _ -> {error, already_started} end.`
- A shared `call(Request)` helper: `Ref = make_ref(), ?MODULE ! {self(), Ref, Request}, receive {Ref, Reply} -> Reply after 1000 -> exit({timeout, Request}) end.`
- `loop(Count)`: `receive {From, Ref, increment} -> From ! {Ref, Count + 1}, loop(Count + 1); {From, Ref, value} -> ...; {From, Ref, reset} -> From ! {Ref, ok}, loop(0); {From, Ref, stop} -> From ! {Ref, ok} end.`
- Registering is racy if two processes race to `start/0`; the test does not race, and real code uses a supervisor instead.
- `whereis` of an unknown name is `undefined`; sending to it is `badarg`; registering a taken name is `badarg`.
- `code_server` is always registered in a running VM.

</details>
