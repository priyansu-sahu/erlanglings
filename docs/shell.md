# Using the Erlang shell to read code

The fastest way to understand a line of Erlang you don't trust is to paste it into
the shell. Every exercise can be explored this way: start `erl`, compile the module,
call it. This page is the minimum you need.

## Start and stop

```sh
erl                      # start a shell
erl -pa _build/05_tagged_tuples   # start with compiled exercise modules on the path
```

Inside the shell every expression ends with `.` and Enter. `q().` quits
(`Ctrl+C` twice also works; `Ctrl+G` then `q` as a last resort).

## Compile and call

```erlang
1> c("exercises/05_tagged_tuples/tagged_tuples.erl").
{ok,tagged_tuples}
2> tagged_tuples:parse_age("42").
{ok,42}
3> tagged_tuples:module_info(exports).
[{parse_age,1},{unwrap,1},...]
```

`c(Mod)` compiles and loads; `l(Mod)` reloads an already compiled `.beam`.

## Shell-only helpers

| Command | Does |
|---|---|
| `f().` | forget all variable bindings (variables are single-assignment, so you need this often) |
| `f(X).` | forget only `X` |
| `rr("exercises/12_records/user.hrl").` | load record definitions so `#user{}` prints as a record instead of a tuple |
| `rp(Term).` | print a term in full (no `...` truncation) |
| `flush().` | print and discard every message in the shell's mailbox |
| `self().` | the shell's pid |
| `i().` | list all processes |
| `regs().` | registered process names |
| `h(lists, foldl).` | documentation for a function (OTP 23+) |
| `observer:start().` | GUI process/ets/application browser (if wx is installed) |

## Inspect a running gen_server

```erlang
1> {ok, Pid} = rate_limiter:start_link(#{limit => 3}).
2> sys:get_state(Pid).
{state,3,#{},#Ref<0.1.2.3>,1000}        % the #state{} record as a plain tuple
3> rr("exercises/24_gen_server_reading/rate_limiter.erl").   % rr works on .erl too
4> sys:get_state(Pid).
#state{limit = 3,buckets = #{},timer = #Ref<...>,refill_ms = 1000}
5> sys:get_status(Pid).      % everything, including the module and parent
6> process_info(Pid, [message_queue_len, memory]).
```

## Trace a function call

`dbg` prints every call and return of a function, live. It is the single most useful
tool for understanding code you did not write.

```erlang
1> dbg:tracer().
2> dbg:p(all, c).                         % trace calls in all processes
3> dbg:tpl(rate_limiter, handle_call, x).   % x = show call and return value
4> rate_limiter:allow(Pid, alice).
(<0.90.0>) call rate_limiter:handle_call({allow,alice},{<0.84.0>,...},{state,3,#{},...})
(<0.90.0>) returned from rate_limiter:handle_call/3 -> {reply,ok,{state,3,#{alice => 2},...}}
5> dbg:stop().
```

`dbg:tp` traces exported functions only; `dbg:tpl` traces local ones too. Never leave
tracing on in production without a limit (`recon_trace` from the `recon` library is
the safe production alternative).

## Reading what the shell prints

- `[104,105]` prints as `"hi"`. If a list of small integers looks like garbage text,
  that is why. Use `io:format("~w~n", [X])` to see the raw list.
- `<<"hi">>` is a binary; `<<104,105>>` is the same binary shown as bytes.
- `#Ref<0.1.2.3>`, `<0.84.0>`, `#Fun<mod.0.123>`, `#Port<0.5>` are references, pids,
  funs and ports. The numbers are not meaningful across runs.
- A record prints as a tuple unless you `rr(...)` its definition.
- `** exception error: ...` is a crash in the shell; the shell itself survives.
