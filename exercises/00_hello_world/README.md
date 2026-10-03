# Hello, World!

Your first Erlang module. This exercise is mostly about learning the loop:
open the file, read the comments, fix the `TODO`, remove the `%% I AM NOT DONE`
line, run the exercise.

## Reading notes

Every `.erl` file you will ever open follows the same skeleton:

```erlang
-module(name).            % attribute: module name, matches the file name
-export([f/0, g/2]).      % attribute: the public API, as name/arity pairs

f() -> ...                % function definitions
```

Things to notice:

- **Attributes** start with `-` and end with `.`. In production modules you
  will see many of them: `-behaviour(gen_server).`, `-include("...").`,
  `-define(...)`, `-spec`, `-type`, `-record`. They are all metadata for the
  compiler; none of them execute at runtime.
- **`name/arity`** is how Erlang code and documentation refer to functions.
  `hello/0` and `hello/1` are different functions. When someone says
  "look at `handle_call/3`", the `/3` is the number of arguments.
- **The last expression is the return value.** There is no `return`.
  When you read a long function body, scan to the final expression before the
  `.` to learn what it produces.
- **Strings are lists** of integer character codes. `"abc"` is `[97, 98, 99]`.
  Production code usually prefers binaries (`<<"abc">>`) for text; you will meet
  those in exercise 09.

## Your task

Make `hello/0` return the string `"Hello, World!"`, then delete the
`%% I AM NOT DONE` line at the top of `hello_world.erl`.

## Run

```sh
./erlanglings run 00_hello_world
```

On Windows (cmd/PowerShell): `erlanglings run 00_hello_world`

## Hints

<details><summary>Hints</summary>

Replace `undefined` with the string literal, in double quotes. Keep the `.` at
the end of the clause.

</details>
