%% I AM NOT DONE
-module(strings_and_binaries).

-export([to_bin/1, to_str/1, greet/1, shout/1, split_csv/1, join_path/1,
         starts_with/2, to_iolist_size/1]).

%% Erlang has three things people call "strings", and production code mixes
%% all three. Telling them apart on sight is essential.
%%
%%   "abc"        string    = list of character codes, [97, 98, 99].
%%                           8 bytes per char in memory (list cell + int).
%%                           Convenient; slow and fat for large text.
%%
%%   <<"abc">>    binary    = packed bytes. The default for text in servers,
%%                           protocol payloads, JSON, anything on the wire.
%%                           O(1) size, cheap to slice, shared when large.
%%
%%   ["a", <<"bc">>, $d, [["e"]]]   iolist = any nesting of lists, binaries
%%                           and bytes. Output functions (file:write, gen_tcp:
%%                           send, io:format) accept iolists directly, so code
%%                           builds output by consing pieces together and NEVER
%%                           concatenates. iolist_to_binary/1 flattens one.
%%
%% Rule of thumb when reading: a server module that handles text will keep it
%% as binaries, build responses as iolists, and only convert to a list when
%% it must call an old API that wants a string.
%%
%% Conversions you will see constantly:
%%   list_to_binary(L)      binary_to_list(B)        (byte-oriented)
%%   unicode:characters_to_binary(S)   unicode:characters_to_list(B)  (UTF-8)
%%   iolist_to_binary(IoList)          iolist_size(IoList)
%%   integer_to_binary(42)  binary_to_integer(<<"42">>)
%%   atom_to_binary(ok)     binary_to_atom(<<"ok">>)   (careful: atom table)
%%   atom_to_list(ok)       list_to_atom("ok")         (same caution)
%%   integer_to_list(42)    list_to_integer("42")
%%
%% The `binary` and `string` modules:
%%   binary:split(B, Pattern)  binary:split(B, Pattern, [global])
%%   binary:part(B, Pos, Len)  binary:match(B, Pattern)  binary:replace/3,4
%%   string:split(S, Sep)  string:split(S, Sep, all)   (works on both!)
%%   string:trim/1  string:uppercase/1  string:lowercase/1  string:join/2
%%   string:to_integer/1  string:prefix/2  string:find/2
%% Modern `string` functions accept and return "chardata", so they work on
%% binaries and lists alike and return the same kind they were given.
%% Older ones (string:tokens/2, string:to_upper/1) are list-only.
%%
%% Concatenation:
%%   "a" ++ "b"                    lists only
%%   <<A/binary, B/binary>>        binaries; the /binary says "whole thing"
%%   [A, B]                        iolist; cheapest, no copying at all
%%
%% The `/binary` and `/utf8` suffixes inside << >> are explained fully in
%% exercise 10. For now: <<X/binary>> splices a binary in; <<"lit">> splices
%% a literal; <<N>> is one byte.

%% TODO: convert a string (list) to a binary.
-spec to_bin(string()) -> binary().
to_bin(Str) ->
    undefined.

%% TODO: convert a binary to a string (list).
-spec to_str(binary()) -> string().
to_str(Bin) ->
    undefined.

%% TODO: build <<"Hello, NAME!">> from a binary Name, using binary syntax
%% (<< ... >>), not list concatenation.
-spec greet(binary()) -> binary().
greet(Name) ->
    undefined.

%% TODO: uppercase a binary and append "!". string:uppercase/1 works on
%% binaries.
%%   shout(<<"hey">>) -> <<"HEY!">>
-spec shout(binary()) -> binary().
shout(Bin) ->
    undefined.

%% TODO: split a comma-separated binary into a list of binaries.
%%   split_csv(<<"a,b,c">>) -> [<<"a">>, <<"b">>, <<"c">>]
%% binary:split/3 with [global], or string:split/3 with `all`.
-spec split_csv(binary()) -> [binary()].
split_csv(Bin) ->
    undefined.

%% TODO: join path segments with "/" into one binary.
%%   join_path([<<"usr">>, <<"local">>, <<"bin">>]) -> <<"usr/local/bin">>
%% lists:join/2 gives an iolist; iolist_to_binary/1 finishes the job.
-spec join_path([binary()]) -> binary().
join_path(Segments) ->
    undefined.

%% TODO: does Bin start with Prefix? Use a binary pattern match with a
%% size taken from byte_size(Prefix), or binary:part/3, or string:prefix/2.
-spec starts_with(binary(), binary()) -> boolean().
starts_with(Bin, Prefix) ->
    undefined.

%% TODO: given an iolist, return {Size, Flattened}, i.e. the total byte count
%% and the single binary it represents.
%%   to_iolist_size(["ab", <<"c">>, [$d]]) -> {4, <<"abcd">>}
-spec to_iolist_size(iolist()) -> {non_neg_integer(), binary()}.
to_iolist_size(IoList) ->
    undefined.
