# Erlanglings

Small exercises to get you **reading** and writing Erlang, in the spirit of
[rustlings](https://github.com/rust-lang/rustlings).

Erlanglings is aimed at engineers who have landed in a large Erlang codebase and need
to become fluent at reading it quickly: the syntax, the idioms, and the OTP patterns
that every production module is built from. Each exercise has a small amount of code
to fix or write, and most also have a **reading** part: you read code and predict what
it returns before the tests tell you whether you were right. Half the exercises in the
last section are *reading only*: a realistic module, and questions about it.

Do the exercises alongside the [official Erlang documentation](https://www.erlang.org/docs),
and keep [`docs/reading_erlang.md`](docs/reading_erlang.md) open as a decoder ring.

## Getting started

### 1. Install Erlang

Any Erlang/OTP 26 or newer.

| Platform | Command |
|---|---|
| macOS | `brew install erlang` |
| Debian / Ubuntu | `sudo apt install erlang` (or packages from [erlang-solutions](https://www.erlang-solutions.com/downloads/)) |
| Windows | `winget install Erlang.ErlangOTP`, or the installer from [erlang.org/downloads](https://www.erlang.org/downloads) |
| Any, via asdf/mise | `mise use -g erlang@27` |
| Docker | `docker run --rm -it -v "$PWD":/work -w /work erlang:27 bash` (no install needed) |

Check it works: `erl -noshell -eval 'io:format("~s~n",[erlang:system_info(otp_release)]), halt().'`

VS Code users can also open the repo in the included dev container.

### 2. Clone

```sh
git clone https://github.com/priyansu-sahu/erlanglings.git
cd erlanglings
```

### 3. Run the first exercise

```sh
./erlanglings            # macOS / Linux / Git Bash
erlanglings              # Windows cmd or PowerShell (uses erlanglings.cmd)
make                     # if you prefer make; wraps the same runner
```

The runner finds the first exercise you have not finished, compiles it, runs its
tests, and tells you what to do next.

## How an exercise works

```
exercises/05_tagged_tuples/
  README.md               what you'll learn, reading notes, your task, hints
  tagged_tuples.erl       the code you edit
  tagged_tuples_tests.erl eunit tests, and "predict the result" questions
```

1. Read the exercise `README.md`. The **Reading notes** section is the point of this
   project: how the construct shows up in real code and what to notice.
2. Open the `.erl` file. Look for `TODO`, `undefined`, or compile errors.
3. In the tests file, replace every `?TODO` with the value you predict. Resist running
   the code first; the reading skill comes from committing to an answer.
4. Run `./erlanglings`. Read the compiler and test output: learning to read *that* is
   part of the exercise.
5. When the tests pass and you understand **why**, delete the `%% I AM NOT DONE` line
   at the top of the file(s) you edited. That marks the exercise complete.

### Runner commands

| Command | What it does |
|---|---|
| `./erlanglings` | run the current exercise |
| `./erlanglings list` | show every exercise and your progress |
| `./erlanglings run 05` | run a specific exercise (number, name, or `05_tagged_tuples`) |
| `./erlanglings hint` | print the hints for the current exercise |
| `./erlanglings watch` | rerun the current exercise every time you save |
| `./erlanglings solution 05` | print the reference solution (try `hint` first) |
| `./erlanglings reset 05` | restore an exercise to its starting state |
| `./erlanglings verify` | maintainers/CI: every solution passes, every starter fails |

The runner is itself a ~450 line Erlang program (`erlanglings`). Reading it after
exercise 15 or so is a good test of progress.

## Exercise list

### Part 1: Syntax and the standard library

| # | Exercise | You will be able to read... |
|---|---|---|
| 00 | hello_world | a module, `-export`, function syntax |
| 01 | basic_types | integers, atoms, strings, binaries, tuples, lists, `$c`, `16#ff` |
| 02 | pattern_matching | `=` as match, destructuring tuples, lists and maps |
| 03 | fix_the_punctuation | `,` `;` `.` and the compiler errors they produce |
| 04 | functions_and_guards | multi-clause functions, `when`, guard `,`/`;` |
| 05 | tagged_tuples | `{ok, V}` / `{error, R}`, `ok = ...` assertions |
| 06 | recursion | body vs tail recursion, the `f(L) -> f(L, [])` accumulator idiom |
| 07 | lists_module | `lists:map/foldl/filter/keyfind/sort/zip/seq` |
| 08 | list_comprehensions | `[X \|\| X <- L, Pred]`, filtering by pattern, binary comprehensions |
| 09 | strings_and_binaries | charlists vs binaries vs iolists, `string:`/`binary:` modules |
| 10 | bit_syntax | `<<V:4, T:4, Len:16/big, Payload:Len/binary>>`: parsing a wire format |
| 11 | map_basics | `=>` vs `:=`, `maps:get/find/update_with/fold` |
| 12 | records | `-record`, `.hrl` includes, `#user{}` patterns and updates |
| 13 | case_if_and_scope | `case`, `if`, variable scope, "unsafe variable" errors |
| 14 | error_handling | `try/catch/after`, `error` vs `throw` vs `exit`, legacy `catch` |
| 15 | funs_and_higher_order | `fun(X) -> ... end`, `fun M:F/A`, closures |
| 16 | macros_and_attributes | `-define`, `?MODULE`, `?LINE`, `-ifdef`, module attributes |
| 17 | type_specs | reading `-spec` and `-type` well enough to implement from them |

### Part 2: Processes

| # | Exercise | You will be able to read... |
|---|---|---|
| 18 | processes | `spawn`, `!`, `receive`, `self()` |
| 19 | receive_and_timeouts | `after`, selective receive, `make_ref()` request/reply |
| 20 | links_and_monitors | `spawn_link`, `trap_exit`, `'EXIT'` and `'DOWN'` messages |
| 21 | server_loop | a hand-rolled stateful server: what gen_server abstracts |
| 22 | registered_processes | `register`, `whereis`, `?MODULE ! Msg` |

### Part 3: OTP

| # | Exercise | You will be able to read... |
|---|---|---|
| 23 | gen_server_basics | `init`, `handle_call`, `handle_cast`, `handle_info`, the reply tuples |
| 24 | gen_server_reading | a complete rate limiter, read-only: predict its behaviour |
| 25 | supervisors | child specs (map and legacy tuple form), restart strategies |
| 26 | gen_statem_reading | a connection state machine, read-only |
| 27 | ets | `ets:new/insert/lookup/update_counter`, match specs |
| 28 | applications | the `.app` file, `application` behaviour, `get_env` |

### Part 4: Reading production code

| # | Exercise | You will be able to read... |
|---|---|---|
| 29 | io_format_reading | `~p ~s ~w ~b ~.2f ~-10s`: log lines and debug output |
| 30 | crash_reasons_reading | `badmatch`, `function_clause`, `case_clause`, `undef`, `noproc`... |
| 31 | otp_module_anatomy_reading | a full gen_server + ets + monitors module, top to bottom |
| 32 | idioms_reading | twenty idioms from large codebases, one line each |

## Reference docs

- [`docs/reading_erlang.md`](docs/reading_erlang.md): the field guide. Punctuation,
  shapes, string types, term order, module anatomy, how to read a crash, glossary.
- [`docs/reading_otp.md`](docs/reading_otp.md): the gen_server call flow, every callback
  and its return values, supervisors, gen_statem, applications.
- [`docs/shell.md`](docs/shell.md): using `erl` to poke at code, `rr`, `sys:get_state`, `dbg`.

## Working environment

Any editor with [erlang-ls](https://erlang-ls.github.io/) support works. For VS Code,
install the [erlang-ls extension](https://marketplace.visualstudio.com/items?itemName=erlang-ls.erlang-ls)
or [Erlang by pgourlain](https://marketplace.visualstudio.com/items?itemName=pgourlain.erlang).
Modern terminals (Windows Terminal on Windows) render the runner output best.

## Continuing on

After erlanglings: read the source of a small OTP module you use every day
(`lists.erl`, `proplists.erl`, `gen_server.erl` itself), then a production module in
your own codebase using the walkthrough from exercise 31. *Learn You Some Erlang*
and *Erlang and OTP in Action* are the classic long-form resources.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md). New reading exercises built from realistic
code are the most valuable kind.

## Credits

Forked from [caatinga/erlanglings](https://github.com/caatinga/erlanglings), which
provided the first three exercises and the idea.
