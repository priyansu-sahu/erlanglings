# Records

Records give names to the positions of a tuple. They are everywhere in
older and mid-age Erlang code (OTP itself, most big production systems),
usually as the shape of a process's state or of a message on the wire.

## Reading notes

- `-record(user, {id, name, status = offline}).` declares the record. It is
  almost always in a `.hrl` header file, pulled in with `-include("user.hrl").`
  or `-include_lib("app/include/user.hrl").`. When you see `#user{...}` and want
  to know the fields, grep for `-record(user,`.
- A record **is a tuple**: `#user{id = 1}` is `{user, 1, undefined, offline, []}`.
  The shell prints the raw tuple unless you load the definition with
  `rr("user.hrl").` (see `docs/shell.md`).
- Four syntaxes to recognize at a glance:
  - construct: `#user{id = 1, name = <<"ann">>}`
  - read a field: `U#user.name`
  - update (returns a new copy): `U#user{status = online}`
  - pattern: `handle(#user{status = online} = U) -> ...`
- `#user.status` with no variable in front is an integer: the field's
  position. You will see it in `lists:keyfind(Id, #user.id, Users)` and in
  `ets` match specs.
- Fields can carry type annotations: `id :: pos_integer()`. Dialyzer reads
  them; the runtime ignores them.
- Modern code often uses maps for the same job. Records are faster to access
  and crash loudly (`badrecord`) when given the wrong shape, which is why
  gen_server state is still usually a `#state{}` record.

## Your task

1. Open `records.erl` and implement the six functions.
2. Open `records_tests.erl` and replace every `?TODO` with the value you
   predict, using the reading notes above.
3. Remove the `%% I AM NOT DONE` line from both files once the tests pass.

## Run

```sh
./erlanglings run 12_records
```

On Windows: `erlanglings run 12_records`.

## Hints

<details>
<summary>Hints</summary>

- `new(Id, Name) -> #user{id = Id, name = Name}.`
- Update syntax: `User#user{status = online}`.
- Two-clause match: `is_online(#user{status = online}) -> true; is_online(#user{}) -> false.`
- The tuple has 1 + (number of fields) elements. Count the fields in `user.hrl`.
- `#user.id` is 2 because position 1 is the record name.
- `is_record({user, 1}, user)` is false: the tuple has the right tag but the wrong size.

</details>
