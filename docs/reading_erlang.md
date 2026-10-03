# A field guide to reading Erlang

This is the page to keep open in a second tab while you read a large Erlang codebase.
It is not a tutorial. It is a decoder ring: *what does this symbol mean, what is this
shape, what should I notice*. The exercises teach each item properly; this page is
for the moment you forget.

## 1. Punctuation is grammar

Erlang punctuation reads like English sentences.

| Symbol | Read it as | Where it appears |
|---|---|---|
| `,` | "and then" | between expressions in a body, elements of a list/tuple, guards (`,` = and) |
| `;` | "or else" | between clauses of a function, `case`, `if`, `receive`, `try`; guards (`;` = or) |
| `.` | "the end" | after every attribute and the last clause of every function |
| `->` | "yields" / "then" | after a function head, case pattern, receive pattern, fun head |
| `when` | "provided that" | starts a guard |
| `=` | "must look like" (match, **not** assign) | everywhere |
| `!` | "send" | `Pid ! Msg` |
| `<-` | "taken from" | list comprehension generator |
| `<=` | "taken from (binary)" | binary comprehension generator |
| `\|\|` | "for each" | list comprehension separator |
| `\|` | "cons" / "followed by the rest" | `[Head \| Tail]` |
| `::` | "has type" | in `-spec` and `-type` |
| `=>` | "maps to" (create/overwrite key) | map construction & update |
| `:=` | "must have key" (match) or "update existing key" | map patterns & updates |
| `#` | "record" or "map" | `#user{}` record, `#{}` map, `16#FF` base |
| `?` | "macro" | `?MODULE`, `?TIMEOUT` |
| `$` | "character code" | `$a` is 97, `$\n` is 10 |
| `_` | "don't care" | any pattern; `_Name` is a documented don't-care |
| `<<` `>>` | "bytes" | binaries and bit syntax |

A function is one sentence:

```erlang
area({square, S})    -> S * S;          % clause 1, "or else"
area({circle, R})    -> 3.14 * R * R;   % clause 2, "or else"
area({rect, W, H})   -> W * H.          % clause 3, "the end"
```

## 2. Variables vs atoms (the most important visual habit)

- **Capitalised or `_`-prefixed = variable.** `State`, `Pid`, `_Unused`, `_`.
- **Lowercase = atom**, a named constant that is only equal to itself. `ok`, `error`,
  `undefined`, `true`, `false`, `gen_server`, `'quoted atom with spaces'`.

So in `handle_call({get, Key}, _From, State)`, the shape `{get, Key}` means "a 2-tuple
whose first element is literally the atom `get`, and whose second element I'll call
`Key`". That one habit lets you read most Erlang.

Variables are **single assignment**. `X = 1, X = 2` crashes with `badmatch`. When you
see `State1`, `State2`, `NewState`, `State0`, that is why.

## 3. Shapes you will see constantly

| Shape | Meaning |
|---|---|
| `{ok, Value}` / `{error, Reason}` | the success/failure convention. Functions that can fail return these |
| `ok = do_thing()` | an assertion: crash right here if it did not return `ok` |
| `{ok, Pid} = start_link()` | assertion + extraction in one line |
| `_ = f()` | "I know this returns something and I'm ignoring it" (quiets linters) |
| `[H \| T]` | non-empty list: first element and the rest |
| `[]` | empty list, often the base case of a recursion |
| `#state{}` | record (named tuple), almost always a gen_server's state |
| `#{key := V}` | map **pattern**: requires `key` to exist |
| `#{key => V}` | map **construction**: creates `key` |
| `M#{key := V}` | map **update**: `key` must already exist, else `badkey` |
| `Rec#state{field = V}` | record update, returns a new record |
| `Rec#state.field` | record field access |
| `fun(X) -> X + 1 end` | anonymous function |
| `fun mod:func/2` | reference to an existing function by name and arity |
| `fun ?MODULE:loop/1` | same, written so hot code loading picks up the new version |
| `<<"text">>` | binary string, **the** text type in production code |
| `<<A:8, Rest/binary>>` | bit syntax: peel one byte off a binary |
| `Mod:Fun(Args)` | fully qualified call; `Mod` can be a variable |
| `?MODULE` | the current module name (expands at compile time) |
| `lists:foldl(fun(X, Acc) -> ... end, Acc0, List)` | the generic loop-with-accumulator |

## 4. Strings: three things that all look like text

| Literal | Type | Notes |
|---|---|---|
| `"abc"` | list of integers `[97,98,99]` | a "string" is sugar for a charlist. The shell prints `[104,105]` as `"hi"` |
| `<<"abc">>` | binary (bytes) | compact, O(1) size, what APIs and protocols use |
| `["a", <<"b">>, $c, ["d"]]` | iolist | nested mix of the two; what `io_lib:format` returns, accepted by `file:write`, sockets, etc. |

Rules of thumb: production code uses binaries for text; `string:` functions accept
both; `iolist_to_binary/1` flattens anything text-like into a binary;
`"abc" == <<"abc">>` is **false**.

## 5. Comparison and term order

- `=:=` exact equal, `=/=` exact not-equal. `==` and `/=` treat `1` and `1.0` as equal.
- Every term is comparable with every other term. The order is:
  `number < atom < reference < fun < port < pid < tuple < map < nil < list < bitstring`.
  So `lists:sort([b, 1, "a", {x}])` is `[1, b, {x}, "a"]`.
- `andalso` / `orelse` short-circuit; `and` / `or` evaluate both sides.

## 6. Control flow is mostly pattern matching

```erlang
case lists:keyfind(Key, 1, Pairs) of
    {Key, Value} -> {ok, Value};
    false        -> {error, not_found}
end
```

- `case` is the workhorse. The scrutinee is matched top to bottom; first match wins.
  No match at all = `{case_clause, Value}` error.
- `if` only has guards and **must** have a branch that is true (usually `true ->`),
  otherwise `if_clause`. Many codebases avoid `if` entirely.
- Multiple function clauses are the preferred "if": `f(0) -> ...; f(N) -> ...`.
- Guards (`when`) can only use a fixed set of built-ins (`is_integer/1`, `length/1`,
  arithmetic, comparisons, `andalso`...). A guard that would crash just fails.
- `try ... of ... catch Class:Reason:Stack -> ... after ... end` for exceptions. The
  three classes are `error` (bugs: `badmatch`, `badarg`, `function_clause`),
  `throw` (non-local return, used deliberately), `exit` (process termination).
- Old code uses `catch Expr`, which returns `{'EXIT', Reason}` on error. It is
  deprecated in new OTP but you will still see it.

## 7. The anatomy of a module

```erlang
-module(session_registry).          % 1. header: name must match file name
-behaviour(gen_server).             %    behaviour declares which callbacks exist

-export([start_link/0, lookup/1]).  % 2. public API (what other modules may call)
-export([init/1, handle_call/3,     %    callbacks, exported but "not for you"
         handle_cast/2, handle_info/2, terminate/2]).

-include("records.hrl").            % 3. includes, macros, records, types
-define(TABLE, ?MODULE).
-record(state, {table :: ets:tid()}).
-type user_id() :: pos_integer().

%%% API ===============================        4. API functions: thin wrappers
lookup(UserId) -> gen_server:call(?MODULE, {lookup, UserId}).

%%% gen_server callbacks ==============        5. where the logic lives
handle_call({lookup, UserId}, _From, State) -> ...

%%% Internal ==========================        6. unexported helpers
```

To read a module fast: exports first (what it offers), then the state record (what it
remembers), then `init/1` (how it starts), then `handle_call/3` clause by clause.
Section banners (`%%% ...`) are navigation markers: jump between them.

## 8. Processes in one paragraph

A process is a lightweight thread with its own heap and a mailbox. `spawn` creates one
and returns a `Pid`. `Pid ! Msg` appends to its mailbox and never blocks. `receive`
scans the mailbox for the **first message matching any pattern**, leaving the others
(this is *selective receive*). `after Ms -> ...` adds a timeout. Processes share
nothing, so state lives in a loop's arguments: `loop(State) -> receive ... -> loop(NewState) end`.
`link`/`monitor` let a process learn when another dies; a supervisor is a process that
restarts the ones it monitors. `gen_server` wraps the loop, the call/reply protocol and
the error handling so you only write the state transitions.

## 9. Reading a crash

```
** exception error: no match of right hand side value {error,enoent}
     in function  config:load/1 (config.erl, line 42)
     in call from app:start/2 (app.erl, line 17)
```

- Read the first line: class (`error`), reason (`badmatch` spelled out), the value.
- The first `in function` line is **where** it happened; following lines are the call stack.
- Common reasons: `badmatch` (a `=` failed), `function_clause` (no clause matched the
  arguments), `case_clause`, `badarg` (a built-in got a wrong-typed arg), `undef`
  (module or function does not exist, or is not exported), `badarith`, `{badkey, K}`,
  `{badrecord, R}`, `noproc` (sent to a dead/unknown process), `timeout`.

Exercise 30 covers each one.

## 10. Glossary of things that look weird the first time

| You see | It is |
|---|---|
| `-spec f(A) -> B when A :: integer(), B :: binary().` | type signature with constraints, pure documentation for dialyzer |
| `-opaque t() :: ...` | type whose structure other modules must not depend on |
| `-callback init(Args) -> ...` | a behaviour declaring what its implementors must export |
| `-ifdef(TEST). ... -endif.` | conditional compilation |
| `-compile(export_all).` | export everything (tests, hacks) |
| `-on_load(f/0).` | run `f/0` when the module loads |
| `begin ... end` | group expressions where one is expected (macros, comprehensions) |
| `catch Expr` | legacy exception swallowing |
| `erlang:'+'(1, 2)` | operators are functions too |
| `F = fun Loop(0) -> done; Loop(N) -> Loop(N - 1) end` | named (recursive) anonymous fun |
| `element(2, Tuple)`, `setelement/3`, `tuple_size/1` | positional tuple access, 1-indexed |
| `hd/1`, `tl/1`, `length/1`, `lists:nth/2` | list access, `nth` is 1-indexed |
| `proplists:get_value(key, Opts, Default)` | options as `[{key, V}]` or bare atoms `[verbose]` |
| `'$1'`, `'_'` | match-spec variables (ets:select, dbg) |
| `{via, Mod, Name}` / `{global, Name}` | process names resolved through a registry |
| `erlang:send_after(Ms, self(), tick)` | a timer that delivers `tick` to `handle_info/2` |
| `sys:get_state(Pid)` | peek inside a running gen_server (debugging) |
| `io:format("~p~n", [X])` | debug print; `~p` pretty, `~s` string, `~w` raw, `~b` integer |
