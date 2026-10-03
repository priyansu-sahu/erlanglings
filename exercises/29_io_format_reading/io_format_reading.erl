%%%-------------------------------------------------------------------
%%% @doc Small helpers around io_lib:format/2, in the style you find in
%%% logging and debugging code everywhere. READ-ONLY for this exercise.
%%%
%%% io:format/2 PRINTS; io_lib:format/2 RETURNS the formatted text as an
%%% iolist (a deep list of characters/binaries). Production code uses
%%% io_lib:format when building log lines or error messages, then flattens
%%% or converts to a binary.
%%% @end
%%%-------------------------------------------------------------------
-module(io_format_reading).

-export([fmt/2, log_line/3, hex/1, pad_id/1, describe_user/1]).

%% Format and flatten to a plain string. io_lib:format returns an iolist
%% such as [[91,"INFO",93]," hello"]; lists:flatten/1 makes it a flat
%% list of characters. (iolist_to_binary/1 is the other common finisher.)
-spec fmt(io:format(), [term()]) -> string().
fmt(Format, Args) ->
    lists:flatten(io_lib:format(Format, Args)).

%% A typical log line builder: "[INFO] 3 users connected".
%% ~s accepts strings, binaries and atoms.
-spec log_line(atom(), io:format(), [term()]) -> string().
log_line(Level, Format, Args) ->
    LevelStr = string:uppercase(atom_to_list(Level)),
    fmt("[~s] ~s", [LevelStr, fmt(Format, Args)]).

%% Hex-encode a binary, two lowercase digits per byte.
%% ~2.16.0b means: width 2, base 16, pad character 0.
-spec hex(binary()) -> string().
hex(Bin) ->
    lists:flatten([io_lib:format("~2.16.0b", [Byte]) || <<Byte>> <= Bin]).

%% Zero-pad an integer id to six digits. ~6..0b: width 6, default
%% precision (the empty field between the dots), pad character 0.
-spec pad_id(non_neg_integer()) -> string().
pad_id(Id) ->
    fmt("~6..0b", [Id]).

%% Mixing ~s for text and ~b for integers is the most common combination
%% in log statements.
-spec describe_user(#{name := binary(), devices := list()}) -> string().
describe_user(#{name := Name, devices := Devices}) ->
    fmt("user ~s has ~b device(s)", [Name, length(Devices)]).
