%% I AM NOT DONE
-module(bit_syntax_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

parse_header_test() ->
    ?assertEqual(#{version => 1, type => 2, flags => 16#80, length => 5},
                 bit_syntax:parse_header(<<1:4, 2:4, 16#80, 0, 5>>)),
    ?assertEqual(#{version => 1, type => 2, flags => 16#80, length => 5},
                 bit_syntax:parse_header(<<1:4, 2:4, 16#80, 0, 5, "trailing">>)),
    ?assertEqual({error, too_short}, bit_syntax:parse_header(<<1, 2, 3>>)).

build_header_test() ->
    ?assertEqual(<<16#12, 0, 1, 0>>, bit_syntax:build_header(1, 2, 256)),
    %% round trip
    Hdr = bit_syntax:build_header(3, 7, 1000),
    ?assertMatch(#{version := 3, type := 7, length := 1000}, bit_syntax:parse_header(Hdr)).

flags_test() ->
    ?assertEqual([compressed], bit_syntax:flags(16#80)),
    ?assertEqual([encrypted], bit_syntax:flags(16#40)),
    ?assertEqual([compressed, encrypted], bit_syntax:flags(16#C0)),
    ?assertEqual([], bit_syntax:flags(16#3F)).

parse_frame_test() ->
    Frame = <<1:4, 2:4, 16#40, 0, 2, "hi", "rest">>,
    ?assertEqual({ok, #{type => 2, flags => [encrypted], payload => <<"hi">>}, <<"rest">>},
                 bit_syntax:parse_frame(Frame)),
    ?assertEqual({more, <<1:4, 2:4, 0, 0, 5, "hi">>},
                 bit_syntax:parse_frame(<<1:4, 2:4, 0, 0, 5, "hi">>)),
    ?assertEqual({more, <<1, 2>>}, bit_syntax:parse_frame(<<1, 2>>)).

build_frame_test() ->
    ?assertEqual(<<1:4, 2:4, 0, 0, 2, "hi">>, bit_syntax:build_frame(2, <<"hi">>)),
    Built = bit_syntax:build_frame(9, <<"payload">>),
    ?assertMatch({ok, #{type := 9, payload := <<"payload">>}, <<>>},
                 bit_syntax:parse_frame(Built)).

parse_all_test() ->
    F1 = bit_syntax:build_frame(1, <<"a">>),
    F2 = bit_syntax:build_frame(2, <<"bb">>),
    Partial = <<1:4, 3:4, 0, 0, 9, "not all">>,
    {Frames, Leftover} = bit_syntax:parse_all(<<F1/binary, F2/binary, Partial/binary>>),
    ?assertMatch([#{type := 1, payload := <<"a">>}, #{type := 2, payload := <<"bb">>}], Frames),
    ?assertEqual(Partial, Leftover),
    ?assertEqual({[], <<>>}, bit_syntax:parse_all(<<>>)).

ipv4_to_string_test() ->
    ?assertEqual("10.0.0.1", bit_syntax:ipv4_to_string(<<10, 0, 0, 1>>)),
    ?assertEqual("255.255.255.0", bit_syntax:ipv4_to_string(<<255, 255, 255, 0>>)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---

%% Default segment size is 8 bits. What does <<1, 2>> look like as a 16-bit
%% integer? (big-endian: first byte is the high byte)
reading_16bit_test() ->
    <<N:16>> = <<1, 2>>,
    ?assertEqual(?TODO, N).

%% Little-endian flips the byte order.
reading_little_endian_test() ->
    <<N:16/little>> = <<1, 2>>,
    ?assertEqual(?TODO, N).

%% Constructing: an integer wider than the segment is truncated to the low
%% bits. What bytes does <<256:8>> hold? And <<256:16>>?
reading_truncation_test() ->
    ?assertEqual(?TODO, <<256:8>>),
    ?assertEqual(?TODO, <<256:16>>).

%% Sub-byte fields. 16#AB is 1010 1011 in binary.
reading_nibbles_test() ->
    <<Hi:4, Lo:4>> = <<16#AB>>,
    ?assertEqual(?TODO, {Hi, Lo}).

%% Length-prefixed field, the classic protocol idiom. What are Body and Rest?
reading_length_prefix_test() ->
    <<Len:8, Body:Len/binary, Rest/binary>> = <<3, "abcdef">>,
    ?assertEqual(?TODO, Body),
    ?assertEqual(?TODO, Rest).

%% For /binary segments the size unit is BYTES; for integers it is BITS.
reading_size_units_test() ->
    <<A:2/binary, B:16, _/binary>> = <<"xyzw">>,
    ?assertEqual(?TODO, A),
    ?assertEqual(?TODO, B =:= (($z bsl 8) bor $w)).

%% Signed vs unsigned view of the same byte.
reading_signed_test() ->
    <<U:8>> = <<255>>,
    <<S:8/signed>> = <<255>>,
    ?assertEqual(?TODO, {U, S}).

%% A match that does not fit the pattern fails like any other match. Which
%% error reason comes out? (The remaining bits do not line up with Rest.)
reading_no_fit_test() ->
    TwoBytes = list_to_binary([1, 2]),
    Result = try
                 <<_:8, _:8, _:8>> = TwoBytes,
                 matched
             catch
                 error:Reason -> Reason
             end,
    ?assertEqual(?TODO, Result).

%% bit_size vs byte_size on a bitstring that is not a whole number of bytes.
reading_bitstring_test() ->
    Bits = <<1:3>>,
    ?assertEqual(?TODO, bit_size(Bits)),
    ?assertEqual(?TODO, is_binary(Bits)).
