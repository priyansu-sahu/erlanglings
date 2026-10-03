# Reading crash reasons

In a "let it crash" system, crashes are normal and the logs are full of them.
The engineers who are fast at debugging production Erlang are the ones who
can glance at `{badmatch, {error, enoent}}` or
`{function_clause, [{mymod, handle, [bad_input], ...}]}` and know, without
looking anything up, what kind of bug they are looking at and where.

`crash_reasons.erl` contains one function per common crash. Predict the
exception class and reason for each one in `crash_reasons_tests.erl`.

## Reading notes

### Three classes

| class | raised by | means |
|---|---|---|
| `error` | the runtime, or `error/1,2` | a bug: bad match, bad argument, missing function... |
| `exit` | `exit/1`, or the runtime ending a process | the process is finishing; `normal`, `shutdown` and `killed` are the conventional reasons |
| `throw` | `throw/1` | non-local return: a value, not a failure. Should always be caught somewhere |

`gen_server:call` turns failures of the *server* into `exit`s in the
*caller*. That is why `noproc` and `timeout` show up as exits.

### The reasons you will meet every day

| reason | what went wrong |
|---|---|
| `{badmatch, Value}` | `Pattern = Expr` failed; `Value` is what `Expr` returned. The single most common crash. `{badmatch, {error, enoent}}` means "someone did `{ok, F} = file:open(...)` and the file was missing" |
| `function_clause` | no clause of the function matched the arguments. The **arguments are in the top stack frame**, not in the reason |
| `{case_clause, Value}` | no branch of a `case` matched `Value` |
| `if_clause` | no `if` guard was true (no `true ->` fallback) |
| `{try_clause, Value}` | the `of` part of a `try` did not match (`of` is not protected by the `catch`) |
| `badarg` | a BIF got the wrong type: `list_to_atom(42)`, `binary_to_integer(<<"x">>)`, `atom ! msg` to an unregistered name, `ets:lookup` on a dead table... the arguments are in the stack trace |
| `badarith` | arithmetic on a non-number |
| `undef` | module not loaded, or function not exported, or wrong arity. Check the stack: `{Mod, Fun, Args, []}` tells you which |
| `{badkey, Key}` | `maps:get/2` or `Map#{Key := V}` with a missing key |
| `{badmap, Value}` | a map operation on a non-map |
| `{badrecord, Value}` | `R#rec.field` where `R` is not a `rec` (older OTP reports the record name instead) |
| `{badfun, Value}` | calling something that is not a fun |
| `{badarity, {Fun, Args}}` | fun called with the wrong number of arguments |
| `{noproc, {gen_server, call, Args}}` | call to a dead or unregistered server |
| `{timeout, {gen_server, call, Args}}` | server did not reply in time (default 5 s). Usually the server is overloaded or deadlocked, not dead |
| `{shutdown, _}`, `shutdown`, `killed` | a supervisor stopped the process; not a bug |
| `noconnection` | the remote node went away |

### How to read a stack trace

```erlang
** exception error: no match of right hand side value {error,not_found}
     in function  crash_reasons:badmatch/0 (crash_reasons.erl, line 33)
     in call from crash_reasons:wrapped/0 (crash_reasons.erl, line 118)
```

Innermost frame first. Each frame is
`{Module, Function, ArityOrArgs, [{file, F}, {line, L}]}`. The third element
is the arity for most errors, but for `function_clause` and `badarg` it is
the **actual argument list**: read it, it is usually the whole answer.
In code, the stack is bound with the three-part catch:

```erlang
try risky() catch Class:Reason:Stacktrace -> ... end
```

### How to read a gen_server crash report

```
=CRASH REPORT==== ...
  crasher:
    initial call: my_server:init/1
    pid: <0.123.0>
    registered_name: my_server
    exception error: no case clause matching {unknown, 5}
      in function  my_server:handle_call/3 (my_server.erl, line 88)
    ...
    last message: {unknown, 5}
    state: {state, ...}
```

Skip to `exception` (the reason), then `in function` (where), then
`last message` (what triggered it) and `state` (what the server knew).
Those four lines explain most crashes.

### Re-wrapping

```erlang
try ... catch error:Reason -> error({config_error, Reason}) end
```

Code often wraps a low-level reason in a more descriptive one. When you see
a nested reason like `{config_error, {badmatch, ...}}`, the innermost term
is the original failure and the outer tags are the path it took.

## Your task

`crash_reasons.erl` is read-only. In `crash_reasons_tests.erl`, replace
each `?TODO` with the `{Class, Reason}` tuple (or pattern, for
`?assertMatch`) you expect.

## Run

```sh
./erlanglings run 30_crash_reasons_reading
```

On Windows: `erlanglings run 30_crash_reasons_reading`.

## Hints

<details><summary>Hints</summary>

* Q1: `{error, {badmatch, {error, not_found}}}`.
* Q2: just `{error, function_clause}`; the `42` is in the stack trace (Q20).
* Q10: the `of` clauses are not protected, so `{error, {try_clause, 1}}`.
* Q12: `{error, {badarity, {_, [1, 2]}}}`.
* Q14 and Q15: the class is `exit`, and the reason is
  `{noproc, {gen_server, call, _}}` / `{timeout, {gen_server, call, _}}`.
* Q18: `{error, {config_error, {badmatch, {error, not_found}}}}`.
* Q20: the argument list, `[42]`.

</details>
