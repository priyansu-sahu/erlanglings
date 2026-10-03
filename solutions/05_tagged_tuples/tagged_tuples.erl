-module(tagged_tuples).

-export([parse_age/1, unwrap/1, unwrap_or/2, lookup/2, all_ok/1]).

%% From here on, exported functions carry a -spec line. Specs are type
%% annotations for tools and readers; they do not affect how the code runs.
%% Exercise 17 explains them. For now, read them as documentation: the
%% arguments' types, an arrow, the return type(s) separated by `|`.

%% Erlang has no exceptions-as-control-flow culture and no Option/Result
%% types. Instead, functions that can fail return a TAGGED TUPLE: a tuple
%% whose first element is an atom saying what kind of value follows.
%%
%%   {ok, Value}            success, with a payload
%%   ok                     success, nothing to return
%%   {error, Reason}        failure; Reason is usually an atom or a small term
%%   error / false / undefined   "not found" from lookup-style functions
%%
%% The caller pattern matches on the tag:
%%
%%   case file:read_file(Path) of
%%       {ok, Bin} -> handle(Bin);
%%       {error, enoent} -> use_default();
%%       {error, Reason} -> exit({cannot_read, Path, Reason})
%%   end
%%
%% or, when failure is not acceptable, asserts the happy path and lets a
%% mismatch crash:
%%
%%   {ok, Bin} = file:read_file(Path)
%%
%% Reading tip: a tag tells you the shape of the rest. Once you see
%% {ok, Pid, Ref} or {reply, Reply, State} you know exactly how many fields
%% follow and roughly what they are. OTP callbacks (gen_server) are all
%% tagged-tuple protocols; getting fluent here pays off later.
%%
%% Different standard library modules use slightly different conventions:
%%   maps:find/2        -> {ok, V} | error
%%   lists:keyfind/3    -> Tuple | false
%%   proplists:get_value/2 -> V | undefined
%%   dict:find/2        -> {ok, V} | error
%% Always check which one a function uses before matching on its result.

%% TODO: parse an age given as a string.
%%   "42"   -> {ok, 42}
%%   "-3"   -> {error, negative}
%%   "abc"  -> {error, not_an_integer}
%% string:to_integer/1 returns {Int, Rest} or {error, no_integer}. Treat any
%% leftover Rest (e.g. "12abc") as not_an_integer too.
-spec parse_age(string()) -> {ok, non_neg_integer()} | {error, negative | not_an_integer}.
parse_age(Input) ->
    case string:to_integer(Input) of
        {N, []} when N < 0 -> {error, negative};
        {N, []} -> {ok, N};
        _ -> {error, not_an_integer}
    end.

%% TODO: {ok, V} -> V. {error, Reason} -> raise an error with that Reason
%% (erlang:error(Reason)).
-spec unwrap({ok, term()} | {error, term()}) -> term().
unwrap({ok, V}) ->
    V;
unwrap({error, Reason}) ->
    erlang:error(Reason).

%% TODO: {ok, V} -> V. Anything else -> Default.
-spec unwrap_or({ok, term()} | term(), term()) -> term().
unwrap_or({ok, V}, _Default) ->
    V;
unwrap_or(_, Default) ->
    Default.

%% TODO: look up Key in a list of {Key, Value} pairs.
%% Return {ok, Value} or the atom error (like maps:find/2).
%% lists:keyfind(Key, 1, List) returns the whole tuple or false.
-spec lookup(term(), [{term(), term()}]) -> {ok, term()} | error.
lookup(Key, Pairs) ->
    case lists:keyfind(Key, 1, Pairs) of
        {Key, Value} -> {ok, Value};
        false -> error
    end.

%% TODO: given a list of results, return {ok, Values} if all are {ok, _},
%% otherwise the FIRST {error, Reason} in the list.
%%   all_ok([{ok, 1}, {ok, 2}])             -> {ok, [1, 2]}
%%   all_ok([{ok, 1}, {error, a}, {error, b}]) -> {error, a}
%% Write it as a recursive function with an accumulator, or use lists:foldr.
-spec all_ok([{ok, term()} | {error, term()}]) -> {ok, [term()]} | {error, term()}.
all_ok(Results) ->
    all_ok(Results, []).

all_ok([], Acc) ->
    {ok, lists:reverse(Acc)};
all_ok([{ok, V} | Rest], Acc) ->
    all_ok(Rest, [V | Acc]);
all_ok([{error, _} = Err | _], _Acc) ->
    Err.
