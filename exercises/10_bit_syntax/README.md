# Bit Syntax

Erlang's bit syntax is why protocol code in Erlang looks like the packet
diagram in the RFC. One pattern reads a header; the same expression, used on
the other side of `=`, writes it. Messaging servers are full of this, so
learn to read `<<Len:16, Body:Len/binary, Rest/binary>>` as one unit.

## Reading notes

A segment is `Value:Size/Specifiers`. Defaults: size 8, type integer,
unsigned, big-endian.

| Segment                     | Means                                              |
|-----------------------------|----------------------------------------------------|
| `<<X>>`                     | one byte                                           |
| `<<X:16>>`                  | 16-bit unsigned, big-endian                        |
| `<<X:32/little-signed>>`    | 32-bit, little-endian, signed                      |
| `<<A:4, B:4>>`              | two 4-bit fields in one byte                       |
| `<<B:N/binary>>`            | N **bytes** as a binary (unit is bytes for binary) |
| `<<Rest/binary>>`           | all remaining bytes; must be the last segment      |
| `<<Rest/bitstring>>`        | remaining bits, when not byte-aligned              |
| `<<F:64/float>>`            | IEEE double                                        |
| `<<C/utf8>>`                | one code point, UTF-8 encoded                      |
| `<<"GET ", Rest/binary>>`   | literal prefix then the rest                       |
| `<<Len:8, Body:Len/binary>>`| length-prefixed field: size from an earlier segment|

The same syntax works in three places and reads differently in each:

```erlang
%% 1. Function head: dispatch on the first bytes
handle(<<0:1, Opcode:7, Rest/binary>>) -> ...;
handle(<<1:1, _:7, _/binary>>) -> ...

%% 2. Match: pull fields out
<<Magic:32, Version:8, Payload/binary>> = Packet,

%% 3. Construct: pack fields in
<<Magic:32, Version:8, (byte_size(Body)):16, Body/binary>>
```

Reading cues:

- **A variable used as a size** (`Body:Len/binary`) must already be bound,
  usually by an earlier segment in the same pattern. This is how variable
  length fields are parsed with no explicit arithmetic.
- **`Rest/binary` as the last segment** means "and keep whatever follows". A
  function returning `{ok, Parsed, Rest}` or `{more, Bin}` is a framing
  loop: it consumes one message and hands back the leftover bytes. Almost
  every TCP handler has one.
- **Function calls inside `<< >>` need parentheses**:
  `<<(byte_size(B)):16>>`. Without them the parser reads it as a segment type.
- **Truncation on construction.** `<<256:8>>` is `<<0>>`; the value is
  reduced modulo 2^Size with no error. Bugs hide here.
- **Byte order matters.** Default big-endian ("network order"). Files and
  hardware protocols often need `/little`.
- **`_` segments** skip bits: `<<_:8, X:8>>`. `_/binary` skips the rest.
- **Bitstrings vs binaries.** A binary is a bitstring whose size is a
  multiple of 8. `<<1:3>>` is a bitstring; `is_binary` is `false` for it.
- **Matching is cheap.** Sub-binaries from a match reference the original,
  so `<<Hdr:4/binary, Rest/binary>>` copies nothing. Chained matches in a
  loop are optimised by the compiler (look up "binary match context" if you
  see `bin_opt_info` warnings).

Common error terms: a binary pattern that does not fit raises
`{badmatch, Bin}` like any match; a bad construction (non-integer value,
negative size) raises `badarg`.

## Your task

1. Implement the seven functions in `bit_syntax.erl`. The frame format is
   drawn in the module's comments.
2. Replace each `?TODO` in `bit_syntax_tests.erl`. Work the bit arithmetic on
   paper first.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 10_bit_syntax
```

On Windows (cmd/PowerShell): `erlanglings run 10_bit_syntax`

## Hints

<details><summary>Hints</summary>

- `parse_header(<<V:4, T:4, Flags:8, Len:16, _/binary>>) -> #{...};`
  plus a catch-all clause returning `{error, too_short}`.
- `build_header(V, T, Len) -> <<V:4, T:4, 0:8, Len:16>>.`
- `flags/1`: `<<C:1, E:1, _:6>> = <<Byte>>`, then build the list from `C`
  and `E` with two small `case` expressions and `++`.
- `parse_frame/1`: one clause with the full pattern including
  `Payload:Len/binary, Rest/binary`; a second clause `parse_frame(Bin) -> {more, Bin}`.
  Because the first clause only matches when all `Len` bytes are present,
  the fall-through handles both "header incomplete" and "payload incomplete".
- `build_frame(Type, P) -> <<1:4, Type:4, 0:8, (byte_size(P)):16, P/binary>>.`
- `parse_all/1`: tail-recursive helper with an accumulator calling `parse_frame/1`.
- `<<1, 2>>` as a 16-bit big-endian integer is `1 * 256 + 2`.

</details>
