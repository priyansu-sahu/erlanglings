# Strings and Binaries

Erlang has no string type. "Text" is one of three things: a list of character
codes (`"abc"`), a binary (`<<"abc">>`), or an iolist (any nesting of the
two). Server code lives in binaries and iolists. Being able to tell at a glance
which one a variable holds is the difference between reading a protocol
handler fluently and guessing.

## Reading notes

| Spelling                    | Type      | Use in production code                          |
|-----------------------------|-----------|-------------------------------------------------|
| `"abc"`                     | list      | literals, old APIs, `io:format` format strings  |
| `<<"abc">>`                 | binary    | everything on the wire, JSON keys, user data    |
| `[<<"a">>, "b", $c, [...]]` | iolist    | output being assembled; passed straight to `send` |

Reading cues:

- **`<<` ... `>>`** anywhere means binary. `<<"GET">>`, `<<Len:16, Rest/binary>>`,
  `<<A/binary, B/binary>>` are literal, pattern, and concatenation respectively.
- **`/binary`** after a variable inside `<< >>` means "splice the whole binary
  in" (building) or "the rest of the bytes" (matching). Exercise 10.
- **`++`** only works on lists. If you see `++` on text, the text is a list.
- **`byte_size/1` vs `length/1` vs `string:length/1`.** `byte_size` counts
  bytes of a binary; `length` counts list elements; `string:length` counts
  characters (grapheme clusters) in either. For UTF-8 these differ.
- **`iolist_to_binary/1`** at the end of a function tells you everything
  above it was building pieces, not concatenating. This is deliberate: lists
  of fragments are O(1) to build, and `gen_tcp:send` and `file:write` accept
  them as-is.
- **`string` module (OTP 20+)** functions accept both lists and binaries and
  return the same kind. `string:split`, `string:trim`, `string:uppercase`,
  `string:prefix`, `string:find`. Older functions (`string:tokens`,
  `string:to_upper`, `string:strip`) are list-only and show up in legacy code.
- **`binary` module** is for byte-level work: `binary:split`, `binary:part`,
  `binary:match`, `binary:copy`, `binary:encode_hex`.

Gotchas:

- `"abc" =:= <<"abc">>` is `false`. Pattern matching `<<"ok">>` against
  `"ok"` fails silently in a `case`. If a function "never matches", check
  the text type first.
- `binary:split(B, Sep)` splits at the **first** occurrence only. Add
  `[global]` for all.
- `list_to_binary/1` accepts an iolist but **rejects** code points above 255.
  For Unicode text use `unicode:characters_to_binary/1`.
- `binary_to_atom/1` and `list_to_atom/1` create atoms, which are never
  garbage collected. Doing this on user input is a known way to exhaust the
  atom table; look for `binary_to_existing_atom/1` in careful code.
- Large binaries (over 64 bytes) are reference-counted and shared between
  processes. Sub-binaries from `binary:part` or pattern matching point into
  the parent and keep it alive. `binary:copy/1` breaks that link.

## Your task

1. Implement the eight functions in `strings_and_binaries.erl`.
2. Replace each `?TODO` in `strings_and_binaries_tests.erl`.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 09_strings_and_binaries
```

On Windows (cmd/PowerShell): `erlanglings run 09_strings_and_binaries`

## Hints

<details><summary>Hints</summary>

- `greet(Name) -> <<"Hello, ", Name/binary, "!">>.`
- `shout(Bin) -> <<(string:uppercase(Bin))/binary, "!">>.` (the parentheses
  are required around a function call inside `<< >>`)
- `split_csv(Bin) -> binary:split(Bin, <<",">>, [global]).`
- `join_path(Segs) -> iolist_to_binary(lists:join(<<"/">>, Segs)).`
- `starts_with/2`:
  ```erlang
  starts_with(Bin, Prefix) ->
      Size = byte_size(Prefix),
      case Bin of
          <<Prefix:Size/binary, _/binary>> -> true;
          _ -> false
      end.
  ```
- `to_iolist_size(L) -> {iolist_size(L), iolist_to_binary(L)}.`

</details>
