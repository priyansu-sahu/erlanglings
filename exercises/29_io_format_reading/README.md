# Reading io:format

Half of the Erlang you read in production is log lines, debug output and
error messages, and all of it goes through `io:format/2`, `io_lib:format/2`
or `logger` with the same format strings. Being able to look at
`"user ~s has ~b devices (~p)"` and know exactly what will come out is a
small skill with a huge payoff: it is how you read logs, and how you spot
the log statement that is about to crash.

## Reading notes

### io vs io_lib

* `io:format(Format, Args)` **prints** and returns `ok`.
* `io_lib:format(Format, Args)` **returns** the text as an *iolist* (a deep
  list of characters and binaries). Code finishes it with `lists:flatten/1`
  (to get a string) or `iolist_to_binary/1` (to get a binary).
* `logger:info("...", [Args])` and the older `error_logger` use the same
  control sequences.

### The control sequences you must know

| sequence | prints | example |
|---|---|---|
| `~p` | the term as Erlang source, **pretty** (strings get quotes, long terms wrap at 80 columns) | `"hello"` prints as `"hello"`, `<<"hi">>` as `<<"hi">>` |
| `~w` | the term as Erlang source, **raw**: no string guessing, no line breaks | `"hi"` prints as `[104,105]` |
| `~s` | a string, binary, atom or iolist as plain text, no quotes | `<<"hi">>` prints as `hi` |
| `~b` | integer, base 10 (`~.16b` for hex) | `255` / `ff` |
| `~f` | float, six decimals by default; `~.2f` for two | `1.000000` / `3.14` |
| `~e` | float in scientific notation | `1.23450e+3` |
| `~c` | a character code as a character | `$a` prints as `a` |
| `~n` | newline | |
| `~~` | a literal `~` | |
| `~P`, `~W` | like `~p`/`~w` but take an extra **depth** argument and print `|...` beyond it | `~P` with depth 5 on `[1..100]` gives `[1,2,3,4|...]` |
| `~ts`, `~tp` | the `t` modifier means Unicode-aware; needed for non-Latin-1 text | |

Field width and padding: `~10s` pads to width 10 (right-justified),
`~-10s` left-justifies, `~6..0b` is width 6 padded with `0`, and
`~2.16.0b` is width 2, base 16, padded with `0` (the standard "one byte as
two hex digits" idiom).

### Things that bite people

* **`~p` on a list of small integers prints a string.** `[104,105]` comes
  out as `"hi"`. When a log line shows a surprising string, suspect a list
  of integers (and reach for `~w`).
* **Argument count must match.** `io_lib:format("~p ~p", [1])` raises
  `badarg`. A log statement with the wrong number of arguments is a crash
  waiting for the first time that code path runs.
* **`~s` needs text.** `~s` with an integer or a tuple is `badarg`; use `~p`
  when unsure what the value is.
* **`~p` wraps long terms** across lines and indents them. Logs of big
  state records look messy for that reason. `~w` never wraps.
* **The arguments are always a list**, even for one value:
  `io:format("~p~n", [Value])`. The `~n` at the end is habitual.

### In the shell

`io:format` is also your main reading tool: paste an expression into the
shell and see what it is. `rp(Term)` prints a term without the depth limit
the shell normally applies.

## Your task

`io_format_reading.erl` is read-only. Open `io_format_reading_tests.erl` and
replace every `?TODO` with the string you expect, written as an Erlang
string literal (for instance `"hello"`, or `"\"hello\""` when the output
itself contains quotes). Q22 asks for an exception reason instead.

## Run

```sh
./erlanglings run 29_io_format_reading
```

On Windows: `erlanglings run 29_io_format_reading`.

## Hints

<details><summary>Hints</summary>

* Q1: `"\"hello\""`. The quotes are part of the output.
* Q4: `"\"hi\""`. Q5: `"<<\"hi\">>"`. Q6: `"<<104,105>>"`.
* Q13: `"    3.14"` has four leading spaces (width 8 minus four characters).
* Q15: `"     hello|"` (five spaces) and `"hello     |"`.
* Q16: `"x\n"`: the newline is a single character inside the string.
* Q17: `"[1,2,3,4|...]"`.
* Q19: `"01ff"`. Q20: `"000042"`.
* Q22: `badarg`.

</details>
