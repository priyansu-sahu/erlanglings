# Macros and module attributes

Anything starting with `?` is a macro, and anything starting with `-` at the
top of a module is an attribute. Both are preprocessor-level: they are
resolved before the compiler proper sees the code. Reading production Erlang
means reading through a layer of `?MODULE`, `?TIMEOUT`, `?LOG(...)` and
`-include` lines, so this exercise makes that layer transparent.

## Reading notes

- `-define(NAME, Value).` defines a constant; `-define(NAME(A, B), Expr).`
  defines a macro with arguments. Use sites look like `?NAME` / `?NAME(1, 2)`.
  Convention is ALL_CAPS. Expansion is textual, so macro bodies are usually
  wrapped in parentheses.
- Predefined: `?MODULE`, `?MODULE_STRING`, `?FUNCTION_NAME`,
  `?FUNCTION_ARITY`, `?LINE`, `?FILE`, `?OTP_RELEASE`. `?MODULE` is the one
  you will see on every page: `gen_server:call(?MODULE, Req)`,
  `register(?MODULE, self())`, `fun ?MODULE:loop/1`.
- Macros can be used in guards as long as their expansion is guard-safe.
  `-define(IS_PORT(P), (is_integer(P) andalso ...))` is a typical example.
- Conditional compilation: `-ifdef(TEST). ... -else. ... -endif.` and
  `-ifndef`. Test-only exports are commonly wrapped in `-ifdef(TEST)`; debug
  logging in `-ifdef(DEBUG)`. rebar3 defines `TEST` when running eunit.
- `-include("x.hrl").` pulls in a header from the source directory or `-I`
  paths; `-include_lib("kernel/include/logger.hrl").` locates the header via an
  installed OTP application's directory. Headers hold records, macros, types.
- Attributes the compiler understands: `-module`, `-export`, `-import`,
  `-behaviour`, `-spec`, `-type`, `-record`, `-define`, `-include`,
  `-compile`, `-vsn`, `-on_load`. Anything else (`-author`, `-doc`, custom
  ones) is stored and readable via `Mod:module_info(attributes)`.
- `module_info/0,1` exists in every module automatically. `module_info(exports)`
  lists the exported functions as `{Name, Arity}` pairs; `module_info(attributes)`
  returns `[{Name, Values}]` where `Values` is a list: `-author(ann).` is stored
  as `{author, [ann]}`, while `-vsn("1.0").` stays `{vsn, "1.0"}` because a
  string already is a list.
- Macro errors are *preprocessor* errors: `undefined macro 'FOO'` means grep
  for `-define(FOO` and check your includes.

## Your task

1. Run the exercise. It fails to compile: `macros.erl` uses a macro that is
   never defined. Add the definition to `macros.hrl` as described there.
2. Open `macros.erl` and implement the stubbed functions using the macros
   described in the comments.
3. Open `macros_tests.erl` and replace every `?TODO` with your prediction.
4. Remove the `%% I AM NOT DONE` lines from all three files once the tests pass.

## Run

```sh
./erlanglings run 16_macros_and_attributes
```

On Windows: `erlanglings run 16_macros_and_attributes`.

## Hints

<details>
<summary>Hints</summary>

- `-define(MAX_RETRIES, 3).` in `macros.hrl`.
- `where_am_i() -> {?FUNCTION_NAME, ?FUNCTION_ARITY}.`
- `is_port(P) when ?IS_PORT(P) -> true; is_port(_) -> false.`
- `retry_label(N) -> "retry " ++ integer_to_list(N) ++ " of " ++ integer_to_list(?MAX_RETRIES).`
- `version()`: `{vsn, Vsn} = lists:keyfind(vsn, 1, ?MODULE:module_info(attributes)), Vsn.`
- Inside `macros_tests.erl`, `?MODULE` is `macros_tests`, not `macros`.
- With DEBUG undefined, `?DEBUG_LOG(...)` expands to the atom `ok`.
- `lists:keyfind(author, 1, Attrs)` returns the whole tuple `{author, [erlanglings]}`.

</details>
