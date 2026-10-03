# Error handling

Erlang's philosophy is "let it crash": most code does not catch errors at
all and relies on a supervisor to restart the process. But at the edges
(parsing input, calling other services, cleaning up resources) you will read
plenty of `try ... catch`, and in older modules plenty of the one-word
`catch Expr` form. This exercise teaches you to read both and to know which
of the three exception classes you are looking at.

## Reading notes

- **Three classes.** `throw(T)` is for expected non-local returns, `error(R)`
  is for bugs and bad input (the runtime uses it: `badarith`, `badmatch`,
  `function_clause`, `badarg`...), and `exit(R)` means "this process is
  done" (also what `gen_server:call` raises on `timeout` or `noproc`).
- **Modern form:**

  ```erlang
  try risky(X) of
      {ok, V} -> V                     % only runs if risky/1 returned; NOT protected
  catch
      throw:Reason -> ...;
      error:Reason:Stack -> ...;       % third element binds the stack trace
      exit:Reason -> ...;
      Class:Reason -> ...              % any class
  after
      cleanup()                        % always runs, value discarded
  end
  ```

  A clause written `catch Reason -> ...` with no class catches **throws
  only**. If you read `catch _ -> ok` and the code is relying on it to swallow
  errors, that is a bug worth noticing.
- **Legacy form:** `catch Expr` evaluates Expr and returns its value, or the
  thrown term, or `{'EXIT', Reason}` for errors and exits. Error reasons
  include the stack trace: `{'EXIT', {badarith, [{erlang, '/', ...}]}}`. The
  idiom `case catch f() of {'EXIT', _} -> ...; V -> ... end` is common in code
  older than ~2015. It is deprecated in OTP 28+, which is why newer code
  avoids it, but you will still read a lot of it.
- **Re-raising** exactly: `erlang:raise(Class, Reason, Stacktrace)`.
- `{ok, V} | {error, Reason}` return values are preferred over exceptions
  for *expected* failures. Exceptions are for the unexpected.
- You will also see `exit(Pid, Reason)` (two arguments) which is not an
  exception at all but a signal sent to another process. Exercise 20 covers it.

## Your task

1. Open `error_handling.erl` and implement the five functions.
2. Open `error_handling_tests.erl` and replace every `?TODO` with your
   prediction. For the ones using `?assertMatch`, write a pattern with `_`
   for the parts you cannot know (like stack traces).
3. Remove the `%% I AM NOT DONE` lines once the tests pass.

## Run

```sh
./erlanglings run 14_error_handling
```

On Windows: `erlanglings run 14_error_handling`.

## Hints

<details>
<summary>Hints</summary>

- `safe_div`: `try {ok, A div B} catch error:badarith -> {error, division_by_zero} end`.
- `classify`: `try Fun() of V -> {ok, V} catch Class:Reason -> {Class, Reason} end`.
- `with_cleanup`: the simplest shape is `try Fun() after Owner ! cleanup_done end`.
  An `after` block re-raises automatically, so you may not need `erlang:raise/3` at all.
- `retry`: a recursive helper `retry(_Fun, 0) -> {error, retries_exhausted}` plus a
  `try Fun() of {ok, V} -> {ok, V}; {error, _} -> retry(Fun, N - 1) catch _:_ -> retry(Fun, N - 1) end`.
- `catch throw(x)` is `x`. `catch exit(x)` is `{'EXIT', x}`. `catch error(x)` is
  `{'EXIT', {x, Stacktrace}}`, so the pattern is `{'EXIT', {x, _}}`.
- Division by zero: `{'EXIT', {badarith, _}}`.
- The `of` body is outside the protection of its own `catch`, so the throw
  propagates to the outer try.
- `catch oops -> ...` does not match `error(oops)`; the outer `error:oops` clause does.

</details>
