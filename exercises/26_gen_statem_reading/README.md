# Reading a gen_statem

`gen_statem` is OTP's state machine behaviour. You meet it wherever a process
has distinct *modes* with different rules in each: connections (connecting,
authenticating, established, closing), sessions, protocol handlers, retry
logic. `ssl`, `ssh` and many connection libraries are gen_statems.

`connection.erl` is a complete gen_statem. You do not change it. Read it and
predict its behaviour in `connection_tests.erl`.

## Reading notes

### How events reach code

In `state_functions` callback mode, **the current state is an atom and there
is one exported function per state**, with the same name:

```erlang
callback_mode() -> state_functions.

disconnected(EventType, EventContent, Data) -> ...
connected(EventType, EventContent, Data)    -> ...
```

So the question "what happens if I call `send/2` while connected?" is
answered by looking for the `{send, _}` clause *inside `connected/3`*. The
same event can be handled completely differently in another state, or not at
all.

The call flow:

```
client: connection:send(Pid, <<"a">>)
  -> gen_statem:call(Pid, {send, <<"a">>})
     -> current state is `connected`, so:
        connected({call, From}, {send, <<"a">>}, Data)
        -> returns {keep_state, NewData, [{reply, From, {ok, 1}}, {state_timeout, 200, idle}]}
  <- {ok, 1}
```

### Event types

| `EventType` | comes from |
|---|---|
| `{call, From}` | `gen_statem:call/2`; reply with the `{reply, From, Reply}` action |
| `cast` | `gen_statem:cast/2` |
| `info` | a plain message (`Pid ! Msg`, timers from `erlang:send_after`, monitors) |
| `state_timeout` | a `{state_timeout, Ms, Content}` action set earlier in this state |
| `timeout` / `{timeout, Name}` | event timeout / generic named timeouts |
| `internal` | an event the machine posted to itself with `{next_event, internal, ...}` |

### Return values

| return | meaning |
|---|---|
| `{next_state, NewState, NewData}` | transition; pending `state_timeout` is cancelled |
| `{next_state, NewState, NewData, Actions}` | transition plus actions |
| `{keep_state, NewData}` / `{keep_state, NewData, Actions}` | stay, update data |
| `keep_state_and_data` / `{keep_state_and_data, Actions}` | stay, touch nothing |
| `{stop, Reason, NewData}` | terminate |

**Actions** is a list; the ones you will see most are `{reply, From, Reply}`,
`{state_timeout, Ms, Content}`, `{next_event, Type, Content}` and `postpone`
(re-deliver this event after the next state change: the way to say "I cannot
handle this yet").

### Things to notice in this module

* `-export([disconnected/3, connected/3]).` is the list of states. In a
  bigger module, that export line is your table of contents.
* Each state function ends with a catch-all clause that delegates to
  `handle_common/3`. Events that mean the same thing everywhere live there.
  Real code often hides this behind a macro (`?HANDLE_COMMON`).
* The `state_timeout` action is re-armed on every `send`. Setting a state
  timeout **replaces** the previous one, so activity pushes the deadline out.
  Leaving the state cancels it. Both facts are easy to miss when reading.
* `sys:get_state(Pid)` returns `{StateName, Data}` for a gen_statem (versus
  the bare state term for a gen_server).
* The sequence counter lives in `Data`, which is *not* reset on a state
  transition. Only `init/1` builds a fresh record.
* The other callback mode, `handle_event_function`, uses one function
  `handle_event(EventType, Event, State, Data)` with the state as an argument.
  Same ideas, different layout; you will see both.

## Your task

Read `connection.erl`. In `connection_tests.erl`, replace each `?TODO` with
the value you expect. Do not edit `connection.erl`.

## Run

```sh
./erlanglings run 26_gen_statem_reading
```

On Windows: `erlanglings run 26_gen_statem_reading`.

## Hints

<details><summary>Hints</summary>

* Q1: look at the second element of the tuple `init/1` returns.
* Q3: the `connect` clause in `connected/3` uses `keep_state_and_data`.
* Q4: `sent` is prepended to (`[Payload | Sent]`), so it is newest-first;
  `history/1` reverses it to oldest-first.
* Q5: `connected(state_timeout, idle, Data)` transitions to `disconnected`.
* Q6: the `send` clause sets a fresh `state_timeout`, so the deadline moves
  to 200 ms after the send. 120 ms later we are still connected.
* Q7: `seq` is only initialised in `init/1`; `next_state` carries `Data`
  over unchanged, so the next send is `{ok, 3}`.
* Q8: `handle_common({call, From}, Event, Data)` replies
  `{error, {unknown_event, Event}}`.
* Q9: record name is `data`.

</details>
