# Reading OTP code: gen_server, supervisors, applications

Almost every long-lived piece of production Erlang is an OTP *behaviour*: a module
that exports a fixed set of callback functions, driven by a generic engine that OTP
provides. Once you can read one gen_server you can read most of a codebase, because
they all have the same skeleton.

## The call flow

The thing to internalise is that **the API function and the callback run in
different processes**.

```
  caller process                               gen_server process
  --------------                               ------------------
  kv:get(Key)
    = gen_server:call(kv, {get, Key})
         |  sends {'$gen_call', {self(), Ref}, {get, Key}}
         |  ------------------------------------------------>  mailbox
         |                                                     |
         |                                      handle_call({get, Key}, From, State)
         |                                        -> {reply, Value, State}
         |  <------------------------------------------------  reply {Ref, Value}
    receives Value
    returns Value
```

- `gen_server:call/2,3` is synchronous: the caller blocks until `handle_call` replies
  (default timeout 5 s, then the **caller** exits with `timeout`).
- `gen_server:cast/2` is fire-and-forget: it returns `ok` immediately and the server
  handles it in `handle_cast/2`. No reply is possible.
- Any other message (`Pid ! Msg`, timers, `'DOWN'`, `'EXIT'`, socket data) arrives in
  `handle_info/2`.

So when reading an API function, find the atom it tags the request with
(`{get, Key}`) and search the file for the `handle_call({get, ...` clause. That is
where the logic is.

## The callbacks and their return values

| Callback | Called when | Must return |
|---|---|---|
| `init(Args)` | `start_link` runs it inside the new process | `{ok, State}` or `{ok, State, Timeout}` or `{stop, Reason}` or `ignore` |
| `handle_call(Req, From, State)` | someone did `gen_server:call` | `{reply, Reply, NewState}` or `{noreply, NewState}` (reply later with `gen_server:reply(From, R)`) or `{stop, Reason, Reply, NewState}` |
| `handle_cast(Msg, State)` | someone did `gen_server:cast` | `{noreply, NewState}` or `{stop, Reason, NewState}` |
| `handle_info(Info, State)` | any other message | same as `handle_cast` |
| `handle_continue(Cont, State)` | previous callback returned `{..., {continue, Cont}}` | same as `handle_cast` |
| `terminate(Reason, State)` | the server is stopping (only guaranteed if trapping exits) | ignored |
| `code_change(OldVsn, State, Extra)` | hot code upgrade | `{ok, NewState}` |

Every return tuple carries the **new state** as the last element. The state is
immutable; "changing" it means returning a new value. If a clause returns the state it
received, nothing changed.

## What to look for in a gen_server

1. **The state record.** `-record(state, {...})` near the top tells you everything the
   server remembers. Typed fields (`limit :: pos_integer()`) are documentation.
2. **How it is named.** `gen_server:start_link({local, ?MODULE}, ?MODULE, Args, [])`
   registers the process under the module name, so API functions can call
   `gen_server:call(?MODULE, ...)` without a Pid. No name means callers must hold a Pid.
3. **`init/1`.** Does it trap exits? Open a table? Start a timer? Return `{ok, State}`
   quickly and defer slow work via `{continue, ...}` or a message to self?
4. **Catch-all clauses.** `handle_call(_Req, _From, State) -> {reply, {error, unknown}, State}`
   and `handle_info(_Info, State) -> {noreply, State}` are defensive. Their absence means
   an unexpected message **crashes the server** (which may be intentional: let it crash).
5. **Timers.** `erlang:send_after(Ms, self(), tick)` lands in `handle_info(tick, State)`.
   Look for the re-arm.
6. **Monitors.** `erlang:monitor(process, Pid)` in one clause pairs with a
   `handle_info({'DOWN', Ref, process, Pid, Reason}, State)` clause somewhere else.
7. **`terminate/2`.** Cleanup. Only reliable if `process_flag(trap_exit, true)` was set in `init`.

## Supervisors

A supervisor's whole job is in `init/1`:

```erlang
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 5,      % max restarts
                 period => 10},       % ...per 10 seconds, else the supervisor itself dies
    Children = [
        #{id       => kv_store,
          start    => {kv_store, start_link, []},
          restart  => permanent,      % permanent | transient | temporary
          shutdown => 5000,           % ms to wait after exit(Pid, shutdown), or brutal_kill
          type     => worker,         % worker | supervisor
          modules  => [kv_store]}
    ],
    {ok, {SupFlags, Children}}.
```

Older code uses tuples, same fields in order:

```erlang
{kv_store, {kv_store, start_link, []}, permanent, 5000, worker, [kv_store]}
{one_for_one, 5, 10}
```

Strategies: `one_for_one` (restart only the dead child), `one_for_all` (restart all),
`rest_for_one` (restart the dead one and those started after it), `simple_one_for_one`
(a dynamic pool of identical children, `supervisor:start_child/2` adds one).

Reading a supervision tree top-down tells you the system's architecture: what is
isolated from what, and what dies together.

## gen_statem

For protocol/connection state machines. Two styles: `state_functions` (one function
per state, `connected(EventType, Event, Data)`) or `handle_event_function` (a single
`handle_event/4`). Returns look like `{next_state, NewState, NewData, Actions}` where
actions include `{reply, From, Reply}`, `{state_timeout, Ms, Msg}`, `postpone`.
Exercise 26 walks through one.

## Applications

An OTP application is a unit of start/stop. `myapp.app` (generated from
`myapp.app.src`) lists its modules, the applications it depends on, default config
(`env`) and the module that starts it (`{mod, {myapp_app, []}}`). `myapp_app:start/2`
starts the top supervisor and returns `{ok, Pid}`. `application:get_env(myapp, key)`
reads config. A *release* is a set of applications plus the VM, started together.

## Common idioms around OTP

- `gen_server:call(Pid, Req, infinity)` for calls that legitimately take long.
- `{noreply, State}` in `handle_call` + a stored `From` = reply later (async work).
- `gen_server:stop/1` vs `exit(Pid, shutdown)`: both run `terminate/2` if exits are trapped.
- `sys:get_state(Pid)` and `sys:get_status(Pid)` to inspect a live server from the shell.
- `proc_lib:spawn_link` + `gen_server:enter_loop` for servers that need custom startup.
- `logger:error("...", [...])` or `?LOG_ERROR(...)` (from `kernel/include/logger.hrl`)
  for logging; older code uses `error_logger` or `lager`.
