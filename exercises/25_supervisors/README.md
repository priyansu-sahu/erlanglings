# Supervisors

A supervisor is a process that starts other processes and restarts them when
they die. Erlang's famous "let it crash" philosophy only works because
supervisors exist: a worker is allowed to crash on unexpected input precisely
because something above it will bring back a clean copy.

Supervisor modules are short, but they are the map of a system. When you open
an unfamiliar application, read its top supervisor first: it tells you which
processes exist and how they depend on each other.

## Reading notes

### The shape

```erlang
-module(my_sup).
-behaviour(supervisor).
-export([start_link/0]).
-export([init/1]).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_one, intensity => 5, period => 10},
    Children = [
        #{id => my_worker, start => {my_worker, start_link, []}}
    ],
    {ok, {SupFlags, Children}}.
```

That is the whole module. Everything interesting is in the two terms
returned by `init/1`.

### Supervisor flags

| flag | meaning |
|---|---|
| `strategy => one_for_one` | restart only the child that died (most common) |
| `strategy => one_for_all` | if one dies, kill and restart all of them |
| `strategy => rest_for_one` | restart the dead child and every child *started after it* |
| `strategy => simple_one_for_one` | many dynamic copies of one child spec (e.g. one per connection) |
| `intensity => 5, period => 10` | more than 5 restarts in 10 s means the supervisor itself gives up and dies, escalating to *its* supervisor |

### Child specs: two formats you will meet

Modern code uses maps:

```erlang
#{id       => counter_worker,                 % required
  start    => {counter_worker, start_link, []}, % required: {M, F, Args}
  restart  => permanent,                      % default
  shutdown => 5000,                           % default for workers
  type     => worker,                         % default
  modules  => [counter_worker]}               % default: [M]
```

Older code (and there is a lot of it) uses a 6-tuple in exactly this order:

```erlang
{counter_worker, {counter_worker, start_link, []}, permanent, 5000, worker, [counter_worker]}
%   Id            StartFunc                        Restart    Shutdown Type   Modules
```

You often see the tuple form wrapped in a macro such as
`?CHILD(Mod, worker)` or `?WORKER(Mod)`; follow the `-define` to decode it.

### Restart types

| `restart =>` | restarted when |
|---|---|
| `permanent` | always, even after a `normal` exit |
| `transient` | only after an abnormal exit (anything but `normal`, `shutdown`, `{shutdown, _}`) |
| `temporary` | never |

### Other things to notice

* `supervisor:start_link` **links** the supervisor to the caller. In
  production the caller is another supervisor (or the application master),
  so a dying top supervisor takes the whole application down, by design.
* Children are started **in list order** and stopped in reverse order. The
  order of the child list is therefore meaningful: dependencies come first.
* Restarting a child gives you a **brand new process with fresh state**.
  Anything the old process kept in its state is gone. State that must
  survive crashes lives somewhere else: ETS owned by a stable process,
  Mnesia, disk, or another node.
* When a child dies you will see a `SUPERVISOR REPORT` in the log with
  `errorContext: child_terminated`, the `reason`, and the `offender` child
  spec. You will see a couple of these when running this exercise; read one.
  Learning to skim these reports quickly is a real production skill.
* `supervisor:which_children/1` and `supervisor:count_children/1` are the
  shell tools for inspecting a live tree. `observer:start()` draws it.

## Your task

1. In `counter_sup.erl`, complete `init/1`: `one_for_one`, intensity 5,
   period 10, and a single child built from `counter_worker:child_spec/0`.
2. In `counter_sup_tests.erl`, answer the reading questions by replacing
   each `?TODO`.

`counter_worker.erl` is read-only.

## Run

```sh
./erlanglings run 25_supervisors
```

On Windows: `erlanglings run 25_supervisors`.

## Hints

<details><summary>Hints</summary>

* `SupFlags = #{strategy => one_for_one, intensity => 5, period => 10}` and
  `Children = [counter_worker:child_spec()]`.
* Q1: the `Id`, `type` and `modules` fields of the child spec come straight
  back from `which_children/1`.
* Q2: the counter lived in the gen_server's state. A restarted process runs
  `init/1` again, which returns `0`.
* Q3: yes. `kill` is an abnormal exit reason (`killed`), and the child is
  `permanent` anyway.
* Q4: `permanent` means restart on *any* exit, including `normal`. If the
  spec said `transient` the answer would be `false`.

</details>
