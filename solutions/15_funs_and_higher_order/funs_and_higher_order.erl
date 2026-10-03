-module(funs_and_higher_order).

-export([make_adder/1, compose/2, apply_n/3, call_each/2, map_with_index/2,
         handler_for/1, handle/1]).

-spec make_adder(number()) -> fun((number()) -> number()).
make_adder(N) ->
    fun(X) -> X + N end.

-spec compose(fun((B) -> C), fun((A) -> B)) -> fun((A) -> C).
compose(F, G) ->
    fun(X) -> F(G(X)) end.

-spec apply_n(fun((T) -> T), non_neg_integer(), T) -> T.
apply_n(_F, 0, X) ->
    X;
apply_n(F, N, X) ->
    apply_n(F, N - 1, F(X)).

-spec call_each([fun((A) -> B)], A) -> [B].
call_each(Funs, Arg) ->
    [F(Arg) || F <- Funs].

-spec map_with_index(fun(({pos_integer(), A}) -> B), [A]) -> [B].
map_with_index(F, List) ->
    lists:map(F, lists:zip(lists:seq(1, length(List)), List)).

-spec handler_for(upper | length | echo) -> fun((binary()) -> term()).
handler_for(upper) -> fun string:uppercase/1;
handler_for(length) -> fun erlang:byte_size/1;
handler_for(echo) -> fun ?MODULE:handle/1.

-spec handle(binary()) -> {handled, binary()}.
handle(Bin) ->
    {handled, Bin}.
