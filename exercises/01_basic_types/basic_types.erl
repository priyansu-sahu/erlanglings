%% I AM NOT DONE
-module(basic_types).

-export([get_integer/0, get_hex/0, get_float/0, get_atom/0, get_boolean/0,
         get_string/0, get_char/0, get_binary/0, get_list/0, get_tuple/0]).

%% Erlang's basic terms, and what they look like in source:
%%
%%   Type      Examples                      Notes
%%   -------   ---------------------------   -------------------------------
%%   integer   42  -7  16#FF  2#1010  $a     arbitrary precision; Base#Digits
%%   float     3.14  1.0e-3                  always has a '.' with digits on both sides
%%   atom      ok  error  'Hello World'      a constant whose only value is its name
%%   boolean   true  false                   just the atoms true and false
%%   string    "abc"                         sugar for the list [97,98,99]
%%   binary    <<"abc">>  <<1,2,255>>        packed bytes; the usual text type
%%   list      [1,2,3]  [H|T]  []            singly linked
%%   tuple     {ok, 42}  {point, 1, 2}       fixed size, first element often a tag
%%   map       #{name => <<"wa">>}           exercise 11
%%   pid       <0.85.0>                      cannot be typed as a literal
%%   fun       fun(X) -> X + 1 end           exercise 13
%%
%% $a is the integer code of the character 'a' (97). You will see $\n, $,
%% and friends when code splits or scans text.
%%
%% Atoms starting with a lowercase letter need no quotes. Anything else
%% ('Hello', 'with space', '') must be single-quoted. Variables start with an
%% uppercase letter or underscore, so `ok` is an atom and `Ok` is a variable.

%% TODO: return the integer 42
get_integer() ->
    undefined.

%% TODO: return 255, written as a hexadecimal literal
get_hex() ->
    undefined.

%% TODO: return the float 3.5
get_float() ->
    undefined.

%% TODO: return the atom erlang
get_atom() ->
    undefined.

%% TODO: return the boolean true
get_boolean() ->
    undefined.

%% TODO: return the string "Hello, Erlang!"
get_string() ->
    undefined.

%% TODO: return the character code of lowercase 'a', using the $ syntax
get_char() ->
    undefined.

%% TODO: return the binary <<"Hello, Erlang!">>
get_binary() ->
    undefined.

%% TODO: return the list [1, 2, 3]
get_list() ->
    undefined.

%% TODO: return the tuple {ok, 42}
get_tuple() ->
    undefined.
