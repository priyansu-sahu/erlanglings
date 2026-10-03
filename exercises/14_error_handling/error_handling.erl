%% I AM NOT DONE
-module(error_handling).

-export([safe_div/2, classify/1, with_cleanup/2, parse_int/1, retry/2]).

%% Erlang has THREE kinds of exceptions. You can tell which one you are
%% looking at by how it was raised:
%%
%%   throw(Term)          -- "non-local return". Used for control flow that is
%%                           expected to be caught (e.g. bailing out of a deep
%%                           recursion). Class: throw.
%%   error(Reason)        -- a genuine bug or bad input. This is what the
%%                           runtime raises for 1/0 (badarith), bad matches,
%%                           bad function calls... Class: error. Carries a
%%                           stack trace.
%%   exit(Reason)         -- "this process should die". Class: exit. Also what
%%                           gen_server:call raises on timeout or dead server.
%%
%% The modern catch form, which you will see in all current code:
%%
%%   try Expr of
%%       Pattern -> ...              % optional: runs if Expr did NOT raise.
%%   catch                           %   NOT protected by the catch below!
%%       throw:Term -> ...;
%%       error:Reason:Stacktrace -> ...;   % the third part binds the stack
%%       exit:Reason -> ...;
%%       _:_ -> ...                  % any class, any reason (use sparingly)
%%   after
%%       cleanup()                   % always runs; its value is discarded
%%   end
%%
%% A bare `Class:Reason` with no class means `throw:Reason`. Code written as
%% `catch _ -> ...` only catches throws, which is a classic reading trap.
%%
%% The OLD form, still common in legacy modules:
%%
%%   catch Expr
%%
%% returns Expr's value if nothing was raised, the thrown Term for throws, and
%% {'EXIT', Reason} for errors (with the stack trace inside Reason) and exits.
%% You will see `case catch some_call() of {'EXIT', _} -> ...; Result -> ...`
%% all over older codebases.

%% {ok, A div B}, or {error, division_by_zero} when B is zero. Use try/catch
%% on the badarith error rather than checking B first.
-spec safe_div(integer(), integer()) -> {ok, integer()} | {error, division_by_zero}.
safe_div(A, B) ->
    undefined.

%% Run Fun. Return {ok, Value} if it returns normally, or {Class, Reason}
%% where Class is throw | error | exit. Do NOT include the stack trace.
-spec classify(fun(() -> term())) -> {ok, term()} | {throw | error | exit, term()}.
classify(Fun) ->
    undefined.

%% Run Fun. Whether or not it raises, send the message `cleanup_done` to
%% Owner. If Fun raised, re-raise with the same class and reason after
%% the message is sent; otherwise return Fun's value.
%%
%% `after` is the tool here. To re-raise exactly, use
%%   erlang:raise(Class, Reason, Stacktrace)
-spec with_cleanup(fun(() -> term()), pid()) -> term().
with_cleanup(Fun, Owner) ->
    undefined.

%% {ok, Integer} if the string is an integer, {error, badarg} otherwise.
%% list_to_integer/1 raises error:badarg on bad input -- catch it.
-spec parse_int(string()) -> {ok, integer()} | {error, badarg}.
parse_int(Str) ->
    undefined.

%% Call Fun up to N times. If it returns {ok, V} return {ok, V}. If it
%% raises (any class) or returns {error, _}, try again. After N failures
%% return {error, retries_exhausted}.
-spec retry(fun(() -> {ok, term()} | {error, term()}), pos_integer()) ->
          {ok, term()} | {error, retries_exhausted}.
retry(Fun, N) ->
    undefined.
