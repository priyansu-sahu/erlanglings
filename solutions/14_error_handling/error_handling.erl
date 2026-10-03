-module(error_handling).

-export([safe_div/2, classify/1, with_cleanup/2, parse_int/1, retry/2]).

-spec safe_div(integer(), integer()) -> {ok, integer()} | {error, division_by_zero}.
safe_div(A, B) ->
    try
        {ok, A div B}
    catch
        error:badarith -> {error, division_by_zero}
    end.

-spec classify(fun(() -> term())) -> {ok, term()} | {throw | error | exit, term()}.
classify(Fun) ->
    try Fun() of
        Value -> {ok, Value}
    catch
        Class:Reason -> {Class, Reason}
    end.

-spec with_cleanup(fun(() -> term()), pid()) -> term().
with_cleanup(Fun, Owner) ->
    try
        Fun()
    after
        Owner ! cleanup_done
    end.

-spec parse_int(string()) -> {ok, integer()} | {error, badarg}.
parse_int(Str) ->
    try
        {ok, list_to_integer(Str)}
    catch
        error:badarg -> {error, badarg}
    end.

-spec retry(fun(() -> {ok, term()} | {error, term()}), pos_integer()) ->
          {ok, term()} | {error, retries_exhausted}.
retry(_Fun, 0) ->
    {error, retries_exhausted};
retry(Fun, N) ->
    try Fun() of
        {ok, Value} -> {ok, Value};
        {error, _Reason} -> retry(Fun, N - 1)
    catch
        _Class:_Reason -> retry(Fun, N - 1)
    end.
