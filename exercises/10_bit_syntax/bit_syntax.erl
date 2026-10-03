%% I AM NOT DONE
-module(bit_syntax).

-export([parse_header/1, build_header/3, parse_frame/1, build_frame/2,
         flags/1, parse_all/1, ipv4_to_string/1]).

%% The bit syntax is how Erlang reads and writes binary protocols. It is the
%% reason Erlang code for packet parsing looks like a diagram of the packet.
%%
%% A segment inside << >> is   Value:Size/TypeSpecifierList
%%
%%   <<X>>                 one byte (Size defaults to 8, type integer)
%%   <<X:16>>              16-bit unsigned big-endian integer
%%   <<X:16/little>>       16-bit little-endian
%%   <<X:32/signed>>       signed
%%   <<X:4, Y:4>>          two 4-bit fields packed into one byte
%%   <<B:3/binary>>        3 BYTES as a binary (size unit is bytes for binary)
%%   <<Rest/binary>>       all remaining bytes (only allowed LAST)
%%   <<F:32/float>>        IEEE float
%%   <<C/utf8>>            one UTF-8 encoded code point
%%   <<"lit", Rest/binary>>  literal prefix, then the rest
%%
%% The same syntax both matches (left of =, or in a function head) and
%% constructs (anywhere else). Size can be a bound variable:
%%
%%   <<Len:8, Body:Len/binary, Rest/binary>> = Packet
%%
%% reads a one-byte length, then exactly Len bytes, then whatever is left.
%% This "length-prefixed field" pattern is THE idiom of protocol code.
%%
%% In this exercise we define a toy frame format:
%%
%%    0        8       16       24       32
%%    +--------+--------+--------+--------+
%%    | ver(4) | type(4)| flags(8)        |  <- byte 0: 4 bits ver, 4 bits type
%%    +--------+--------+--------+--------+     byte 1: flags
%%    | length (16 bits, big-endian)      |     bytes 2-3: payload length
%%    +--------+--------+--------+--------+
%%    | payload ... (length bytes)        |
%%    +-----------------------------------+
%%
%% flags byte:  bit 7 = compressed, bit 6 = encrypted, bits 5..0 unused.
%%
%% Note how parse_header/1 below reads like the diagram. When you read real
%% protocol modules, find the -spec and the first binary pattern; between
%% them they are the packet specification.

%% TODO: parse the 4-byte header into a map.
%%   parse_header(<<1:4, 2:4, 16#80, 0, 5>>) ->
%%       #{version => 1, type => 2, flags => 16#80, length => 5}
%% Return {error, too_short} for anything shorter than 4 bytes.
-spec parse_header(binary()) -> #{version := 0..15, type := 0..15,
                                  flags := byte(), length := 0..65535}
                              | {error, too_short}.
parse_header(Bin) ->
    undefined.

%% TODO: the inverse: build the 4-byte header, given Version, Type and a
%% payload Length. Set flags to 0.
-spec build_header(0..15, 0..15, 0..65535) -> <<_:32>>.
build_header(Version, Type, Length) ->
    undefined.

%% TODO: decode the flags byte into a list of atoms, in this order:
%%   flags(16#80) -> [compressed]
%%   flags(16#40) -> [encrypted]
%%   flags(16#C0) -> [compressed, encrypted]
%%   flags(0)     -> []
%% Match the two top bits with <<C:1, E:1, _:6>>.
-spec flags(byte()) -> [compressed | encrypted].
flags(Byte) ->
    undefined.

%% TODO: parse one complete frame: header followed by exactly `length` bytes
%% of payload, then possibly more data.
%% Return {ok, #{type => T, flags => [..], payload => Payload}, Rest}
%% or {more, Bin} if the binary does not yet hold a whole frame (this is
%% what a TCP handler returns to say "wait for more bytes").
-spec parse_frame(binary()) -> {ok, map(), binary()} | {more, binary()}.
parse_frame(Bin) ->
    undefined.

%% TODO: build a frame for Type with Payload, version 1, flags 0.
%%   build_frame(2, <<"hi">>) -> <<1:4, 2:4, 0, 0, 2, "hi">>
-spec build_frame(0..15, binary()) -> binary().
build_frame(Type, Payload) ->
    undefined.

%% TODO: parse every complete frame in Bin. Return {Frames, Leftover} where
%% Frames is a list of the maps parse_frame/1 produces and Leftover is the
%% trailing partial data (<<>> if none). Loop on parse_frame/1 until it
%% says {more, _}.
-spec parse_all(binary()) -> {[map()], binary()}.
parse_all(Bin) ->
    undefined.

%% TODO: an IPv4 address packed into 4 bytes -> dotted string.
%%   ipv4_to_string(<<10, 0, 0, 1>>) -> "10.0.0.1"
%% Match the four bytes, then io_lib:format("~b.~b.~b.~b", [...]) and
%% lists:flatten. (inet:ntoa/1 does this for real; write it yourself here.)
-spec ipv4_to_string(<<_:32>>) -> string().
ipv4_to_string(Bin) ->
    undefined.
