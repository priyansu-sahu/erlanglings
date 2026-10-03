%% I AM NOT DONE
-module(funs_and_higher_order).

-export([make_adder/1, compose/2, apply_n/3, call_each/2, map_with_index/2,
         handler_for/1, handle/1]).

%% Anonymous functions ("funs") come in a few spellings. All of these are
%% values you can pass around, store in state, or send in a message:
%%
%%   fun(X) -> X + 1 end                an anonymous fun
%%   fun(X) when X > 0 -> pos; (_) -> nonpos end   clauses, like a named function
%%   fun local_name/1                   reference to a function in THIS module
%%   fun lists:reverse/1                reference to a function in another module
%%   fun ?MODULE:handle/1               reference that goes through the module
%%                                      name -- picks up the NEWEST code after a
%%                                      hot code upgrade. Very common in long-lived
%%                                      servers.
%%   fun Loop(0) -> done; Loop(N) -> Loop(N - 1) end   named fun (recursive)
%%
%% Calling: F(Arg), or apply(F, [Arg]), or apply(Module, Function, [Args]).
%% The "M:F/A" notation in docs and stack traces means Module:Function/Arity.
%%
%% Closures capture the variables in scope when the fun is created. Since
%% variables never change, a captured value is frozen -- which is why funs
%% are safe to send to other processes.

%% Return a fun that adds N to its argument.
-spec make_adder(number()) -> fun((number()) -> number()).
make_adder(N) ->
    undefined.

%% Return a fun G such that G(X) = F(Gx(X))... i.e. compose(F, G)(X) == F(G(X)).
-spec compose(fun((B) -> C), fun((A) -> B)) -> fun((A) -> C).
compose(F, G) ->
    undefined.

%% Apply F to X, N times: apply_n(F, 3, X) == F(F(F(X))).
-spec apply_n(fun((T) -> T), non_neg_integer(), T) -> T.
apply_n(F, N, X) ->
    undefined.

%% Call each fun in the list with Arg and collect the results.
-spec call_each([fun((A) -> B)], A) -> [B].
call_each(Funs, Arg) ->
    undefined.

%% Like lists:map/2 but F receives {Index, Element} with Index starting at 1.
%% lists:zip/2 and lists:seq/2 make this a one-liner.
-spec map_with_index(fun(({pos_integer(), A}) -> B), [A]) -> [B].
map_with_index(F, List) ->
    undefined.

%% Dispatch tables are a common idiom: map a tag to a fun.
%% Return a fun for the given tag:
%%   upper  -> a fun that upper-cases a binary (string:uppercase/1)
%%   length -> a fun that returns byte_size of a binary
%%   echo   -> a reference to this module's handle/1, written with ?MODULE
-spec handler_for(upper | length | echo) -> fun((binary()) -> term()).
handler_for(Tag) ->
    undefined.

-spec handle(binary()) -> {handled, binary()}.
handle(Bin) ->
    {handled, Bin}.
