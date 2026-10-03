%%%-------------------------------------------------------------------
%%% @doc One function per common crash. READ-ONLY for this exercise.
%%%
%%% Each function below fails in a specific, recognisable way. Your job
%%% (in crash_reasons_tests.erl) is to predict the exception CLASS
%%% (error | exit | throw) and the REASON term for each one, the way you
%%% would when reading a crash report in a log.
%%% @end
%%%-------------------------------------------------------------------
-module(crash_reasons).

-export([badmatch/0, function_clause/0, case_clause/0, badarg/0,
         badarith/0, undef/0, badkey/0, badmap/0, if_clause/0,
         try_clause/0, badfun/0, badarity/0, badrecord/0, noproc/0,
         timeout/0, throw_value/0, exit_shutdown/0, wrapped/0]).

-record(user, {id, name}).

%% The compiler is clever enough to warn about most of the crashes below
%% if it can see the constants. Routing values through opaque/1 hides them
%% from the optimiser so the module compiles cleanly, exactly as if the
%% values had come from a message or a database.
-spec opaque(term()) -> term().
opaque(Term) ->
    binary_to_term(term_to_binary(Term)).

%% `=' is a match. Matching {ok, _} against {error, not_found} fails.
badmatch() ->
    {ok, Value} = lookup(opaque(missing)),
    Value.

lookup(missing) -> {error, not_found};
lookup(Key) -> {ok, Key}.

%% No clause of only_atoms/1 accepts 42.
function_clause() ->
    only_atoms(opaque(42)).

only_atoms(A) when is_atom(A) -> {atom, A}.

%% No branch of the case matches 3.
case_clause() ->
    case opaque(3) of
        1 -> one;
        2 -> two
    end.

%% A BIF called with an argument of the wrong type.
badarg() ->
    list_to_atom(opaque(42)).

%% Arithmetic on a non-number.
badarith() ->
    opaque(a) + 1.

%% Calling a function that does not exist (module not found, or the
%% function/arity is not exported).
undef() ->
    definitely_missing_module:run().

%% maps:get/2 on a missing key. (Compare: a pattern match #{k := V} on a
%% missing key is a badmatch, not a badkey.)
badkey() ->
    maps:get(name, opaque(#{port => 80})).

%% A map operation on something that is not a map.
badmap() ->
    maps:get(port, opaque(not_a_map)).

%% `if' has no `true' fallback clause and nothing matches.
if_clause() ->
    X = opaque(1),
    if
        X > 10 -> big
    end.

%% The `of' section of a try is NOT protected by the catch: a non-matching
%% value there raises try_clause.
try_clause() ->
    try opaque(1) of
        10 -> ten
    catch
        _:_ -> never_reached
    end.

%% Calling something that is not a fun.
badfun() ->
    F = opaque(not_a_fun),
    F(1).

%% Calling a fun with the wrong number of arguments.
badarity() ->
    F = opaque(fun(X) -> X end),
    F(1, 2).

%% Accessing a record field of a tuple that is not that record.
badrecord() ->
    R = opaque({person, 1}),
    R#user.name.

%% gen_server:call to a registered name that does not exist.
noproc() ->
    gen_server:call(no_such_registered_server, ping).

%% gen_server:call that is never answered. The exit reason carries the
%% MFA of the call, which is how you find the caller in a log.
timeout() ->
    Pid = spawn(fun() -> receive after infinity -> ok end end),
    try
        gen_server:call(Pid, ping, 50)
    after
        exit(Pid, kill)
    end.

%% throw/1 is for non-local return, not for errors; its "reason" is just
%% the thrown value.
throw_value() ->
    throw({not_an_error, just_a_value}).

%% exit/1 ends the process with the given reason. `shutdown' is the
%% conventional reason for an orderly stop.
exit_shutdown() ->
    exit(shutdown).

%% The re-wrap idiom: catch a low-level error and raise a more descriptive
%% one. You will see this a lot; the original reason is kept inside.
wrapped() ->
    try
        badmatch()
    catch
        error:Reason ->
            error({config_error, Reason})
    end.
