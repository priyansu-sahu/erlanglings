%% Header files hold things shared between modules: record definitions,
%% macros, and type declarations. This one is included by macros.erl.
%%
%% Macro syntax:
%%   -define(NAME, Value).            constant macro, used as ?NAME
%%   -define(NAME(A, B), Expr).       macro with arguments, used as ?NAME(x, y)
%%
%% Macros are textual substitution done by the preprocessor BEFORE compiling.
%% Convention: ALL_CAPS for constants. Arguments inside the body are usually
%% wrapped in parentheses to avoid precedence surprises.

-define(MAX_RETRIES, 3).

%% A macro usable inside guards: only guard-safe expressions allowed, and
%% `andalso`/`orelse` are fine there.
-define(IS_PORT(P), (is_integer(P) andalso P > 0 andalso P =< 65535)).

%% Debug-only code. `-ifdef(DEBUG)` keeps the first definition only when the
%% DEBUG macro is defined (e.g. with `erlc -DDEBUG`); otherwise the -else
%% branch is used. Production builds compile this away entirely.
-ifdef(DEBUG).
-define(DEBUG_LOG(Fmt, Args), io:format("[debug] " ++ Fmt ++ "~n", Args)).
-else.
-define(DEBUG_LOG(Fmt, Args), ok).
-endif.
