%% I AM NOT DONE
%%
%% Welcome to Erlanglings. Every exercise starts with the line above.
%% When you think you are done, delete that line and run the exercise again.
%%
%% An Erlang source file holds exactly one module. The module name must match
%% the file name (hello_world.erl -> hello_world).
-module(hello_world).

%% Only exported functions can be called from outside the module.
%% `hello/0` means "the function named hello that takes 0 arguments".
%% Name + arity together identify a function; hello/0 and hello/1 would be
%% two completely unrelated functions.
-export([hello/0]).

%% A function is one or more clauses. Each clause is
%%     Name(Args) -> Body.
%% The body is a sequence of expressions separated by commas; the value of
%% the last expression is the return value. There is no `return` keyword.
%% Strings in double quotes are lists of integers (character codes).

%% TODO: make hello/0 return the string "Hello, World!"
hello() ->
    undefined.
