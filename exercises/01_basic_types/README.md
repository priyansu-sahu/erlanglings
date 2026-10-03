# Basic Types

Erlang has a small set of built-in types and no user-defined ones (records and
maps are built from tuples and maps, as you'll see later). Once you can tell
them apart on sight, most of the "what is this value?" questions you have
while reading code answer themselves.

## Reading notes

How each type looks in real code, and how to recognise it:

| You see                | It is        | Notes                                                        |
|------------------------|--------------|--------------------------------------------------------------|
| `42`, `-1`, `16#FF`, `$a` | integer   | `Base#Digits` for other bases; `$c` is a character code       |
| `1.0`, `2.5e3`         | float        | `1.` and `.5` are not valid floats                            |
| `ok`, `error`, `'Quoted'` | atom      | lowercase start or quoted; a named constant                  |
| `true`, `false`        | boolean      | just atoms                                                    |
| `"text"`               | string       | really a list of integers                                     |
| `<<"text">>`, `<<0,1>>`| binary       | bytes; the common text type in servers                        |
| `[1, 2]`, `[H \| T]`    | list         | linked list; `\|` splits head and tail                        |
| `{ok, V}`              | tuple        | fixed size; first element usually a tag atom                  |
| `#{k => v}`            | map          | exercise 11                                                   |
| `<0.123.0>`            | pid          | shows up in logs and the shell, never as a literal in source  |
| `#Ref<0.1.2.3>`        | reference    | unique token, from `make_ref()` or `monitor`                  |
| `fun(X) -> ... end`    | fun          | exercise 13                                                   |

Gotchas that bite people reading Erlang for the first time:

- **Case matters for identity.** `ok` is an atom, `Ok` is a variable. `_Ok`
  is a variable whose value the author chose to ignore (the leading underscore
  silences the unused-variable warning).
- **Atoms are not strings.** `ok` and `"ok"` and `<<"ok">>` are three different
  values that do not compare equal. Pattern matching on the wrong one is a
  classic bug.
- **`==` vs `=:=`.** `1 == 1.0` is `true`, `1 =:= 1.0` is `false`. Idiomatic
  code uses `=:=` and `=/=` almost everywhere.
- **`/` always produces a float.** Integer division is `div`, remainder is `rem`.
- **Large integers are fine.** `1 bsl 128` is a normal integer. You will not
  see overflow handling in Erlang code.
- **Term ordering is total.** Any two terms can be compared:
  `number < atom < reference < fun < port < pid < tuple < map < nil < list < bitstring`.
  This is why `lists:sort/1` works on anything and why
  `lists:max([1, a, "x"])` has a defined answer.

## Your task

1. Fill in the ten `get_*` functions in `basic_types.erl`.
2. In `basic_types_tests.erl`, replace every `?TODO` with the value you
   predict. Read the expression, decide, then run to check.
3. Remove the `%% I AM NOT DONE` line from both files.

## Run

```sh
./erlanglings run 01_basic_types
```

On Windows (cmd/PowerShell): `erlanglings run 01_basic_types`

## Hints

<details><summary>Hints</summary>

- A hexadecimal literal: `16#FF`.
- The character code for `a`: `$a`.
- Binaries: `<<"Hello, Erlang!">>`.
- When an assertion fails EUnit shows `expected` and `value`. The `value` line
  is the answer the code actually produced; compare it to your prediction and
  think about why they differ before copying it in.

</details>
