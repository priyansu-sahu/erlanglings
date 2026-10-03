# Contributing

Thanks for helping make erlanglings better. The bar for a new exercise is simple:
**would this help someone get fluent at reading real Erlang faster?**

## Anatomy of an exercise

```
exercises/NN_topic/
  README.md          what you'll learn, reading notes, the task, hints
  topic.erl          the file(s) the learner edits
  topic_tests.erl    eunit tests; also where "predict the output" questions live
solutions/NN_topic/
  topic.erl          the finished version of every file the learner edits
```

Rules the runner (`./erlanglings`) relies on:

- Every file the learner must edit starts with the line `%% I AM NOT DONE`.
  An exercise is "done" when no `.erl` or `.hrl` file in its directory contains that line.
- Read-only files (a module to read, a `.hrl`, a `.app`) do **not** carry the marker.
- Prediction questions use `-define(TODO, '__TODO__').` in the tests file and
  `?TODO` where the learner's answer goes.
- The starter must **fail** (compile error or failing tests) and the solution must
  **pass**. `./erlanglings verify` checks both for every exercise and runs in CI.
- Every `.erl` file is compiled, with the exercise directory on the include path.
  Every module whose name ends in `_tests` is run with eunit.

## Writing a good exercise

- Lead with *reading*. Explain what the construct looks like in production code,
  what to notice, and the gotchas, before asking the learner to write anything.
- Keep the code idiomatic: `-spec`s, `?MODULE`, tagged tuples, records with typed
  fields, `%%%` section banners in OTP modules. Learners pattern-match on what they see.
- Prefer `?assertMatch` over `?assertEqual` for terms that differ across OTP versions.
- Tests must clean up after themselves (no leftover registered names, ets tables or
  loaded applications) and use short timeouts.
- ASCII only inside `.erl` files.

## Checking your work

```sh
./erlanglings verify NN_topic   # one exercise
./erlanglings verify            # everything (what CI runs)
```
