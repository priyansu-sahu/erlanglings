%%%-------------------------------------------------------------------
%%% @doc A grab-bag of small idioms that show up constantly in large
%%% Erlang codebases. READ-ONLY for this exercise.
%%%
%%% None of these functions is interesting on its own. Together they are
%%% the vocabulary you need to skim real code without stopping.
%%% @end
%%%-------------------------------------------------------------------
-module(idioms).

%% The bare `catch Expr' form (see swallow/1) is deprecated in new OTP
%% releases in favour of try ... catch ... end, but it is still extremely
%% common in older code. This directive silences the deprecation warning so
%% the example compiles cleanly.
-compile(nowarn_deprecated_catch).

-export([get_opt/3, ensure_binary/1, to_int/1,
         safe_call/1, swallow/1, first_ok/1,
         index_by/2, bump/2, pipe/2,
         is_normal_exit/1, hash_bucket/2, now_ms/0]).

%% Read an option from either a proplist or a map, with a default.
%% Code that accepts "Opts" very often has to cope with both shapes.
-spec get_opt(term(), [tuple() | atom()] | map(), term()) -> term().
get_opt(Key, Opts, Default) when is_map(Opts) ->
    maps:get(Key, Opts, Default);
get_opt(Key, Opts, Default) when is_list(Opts) ->
    proplists:get_value(Key, Opts, Default).

%% Normalise "something text-like" to a binary. Production code is binary
%% all the way down; this kind of coercion lives at the edges.
-spec ensure_binary(binary() | string() | atom() | integer()) -> binary().
ensure_binary(Bin) when is_binary(Bin) -> Bin;
ensure_binary(List) when is_list(List) -> unicode:characters_to_binary(List);
ensure_binary(Atom) when is_atom(Atom) -> atom_to_binary(Atom, utf8);
ensure_binary(Int) when is_integer(Int) -> integer_to_binary(Int).

%% Same idea for integers arriving as text.
-spec to_int(binary() | string() | integer()) -> integer().
to_int(Bin) when is_binary(Bin) -> binary_to_integer(Bin);
to_int(List) when is_list(List) -> list_to_integer(List);
to_int(Int) when is_integer(Int) -> Int.

%% Turn any exception into an {error, _} tuple. Note Class:Reason in the
%% catch: without a class, `catch Reason ->' only catches throws.
-spec safe_call(fun(() -> term())) -> {ok, term()} | {error, {atom(), term()}}.
safe_call(Fun) ->
    try
        {ok, Fun()}
    catch
        Class:Reason -> {error, {Class, Reason}}
    end.

%% "Best effort": run Fun, ignore whatever happens. The `_ =' says "I know
%% there is a return value and I am deliberately dropping it". The bare
%% `catch' returns the value, or {'EXIT', Reason} for errors/exits, or the
%% thrown term for throws. You will see this in cleanup code.
-spec swallow(fun(() -> term())) -> ok.
swallow(Fun) ->
    _ = (catch Fun()),
    ok.

%% Try alternatives in order until one returns {ok, _}. `{ok, _} = Ok' in a
%% case clause both checks the shape and binds the whole value to Ok.
-spec first_ok([fun(() -> term())]) -> {ok, term()} | {error, none}.
first_ok([]) ->
    {error, none};
first_ok([Fun | Rest]) ->
    case Fun() of
        {ok, _} = Ok -> Ok;
        _ -> first_ok(Rest)
    end.

%% Build a map from a list, keyed by whatever KeyFun extracts. The foldl
%% with an accumulator map is THE way to build an index.
-spec index_by(fun((term()) -> term()), [term()]) -> map().
index_by(KeyFun, List) ->
    lists:foldl(fun(Elem, Acc) -> Acc#{KeyFun(Elem) => Elem} end, #{}, List).

%% Increment a counter in a map, starting from 1 if absent.
-spec bump(term(), map()) -> map().
bump(Key, Counts) ->
    maps:update_with(Key, fun(N) -> N + 1 end, 1, Counts).

%% Thread a value through a list of functions, left to right.
-spec pipe(term(), [fun((term()) -> term())]) -> term().
pipe(Value, Funs) ->
    lists:foldl(fun(F, Acc) -> F(Acc) end, Value, Funs).

%% The three exit reasons that mean "stopped on purpose". Supervisors use
%% exactly this rule for `transient' children.
-spec is_normal_exit(term()) -> boolean().
is_normal_exit(normal) -> true;
is_normal_exit(shutdown) -> true;
is_normal_exit({shutdown, _}) -> true;
is_normal_exit(_) -> false.

%% Consistent bucketing: phash2/2 returns 0..N-1 and is stable across
%% nodes and OTP versions, so it is used for sharding and partitioning.
-spec hash_bucket(term(), pos_integer()) -> non_neg_integer().
hash_bucket(Term, Buckets) ->
    erlang:phash2(Term, Buckets).

%% Wall-clock milliseconds. For measuring durations use
%% erlang:monotonic_time/1 instead; system time can jump.
-spec now_ms() -> integer().
now_ms() ->
    erlang:system_time(millisecond).
