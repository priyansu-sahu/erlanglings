%% I AM NOT DONE
-module(macros).

%% Module attributes: anything of the form `-name(Value).` before the first
%% function. The compiler knows some (module, export, include, define, spec,
%% behaviour, vsn); anything else is a custom attribute stored in the module
%% and readable at runtime via macros:module_info(attributes).
-vsn("1.2.0").
-author(erlanglings).

%% -include("file.hrl")       looks relative to the source file and -I paths.
%% -include_lib("app/include/file.hrl")  looks inside an installed OTP application.
-include("macros.hrl").

-export([max_retries/0, module_name/0, module_string/0, where_am_i/0,
         is_port/1, retry_label/1, with_timeout/1, version/0]).

%% Predefined macros you will see constantly:
%%   ?MODULE          the module name as an atom      (macros)
%%   ?MODULE_STRING   the module name as a string     ("macros")
%%   ?FUNCTION_NAME   the enclosing function's name   (atom)
%%   ?FUNCTION_ARITY  its arity                       (integer)
%%   ?LINE            the current line number
%%   ?FILE            the source file name
%%
%% `?MODULE` is the big one. Servers register themselves as ?MODULE, call
%% themselves with gen_server:call(?MODULE, ...), and refer to their own
%% functions as fun ?MODULE:f/1 so that renaming a module needs no edits.

-define(DEFAULT_TIMEOUT, 5000).

%% Return the value of the MAX_RETRIES macro (defined in macros.hrl).
-spec max_retries() -> pos_integer().
max_retries() ->
    ?MAX_RETRIES.

%% Return this module's name as an atom, using a macro (not a literal).
-spec module_name() -> atom().
module_name() ->
    undefined.

%% Return this module's name as a string, using a macro.
-spec module_string() -> string().
module_string() ->
    undefined.

%% Return {FunctionName, Arity} for THIS function, using macros.
-spec where_am_i() -> {atom(), non_neg_integer()}.
where_am_i() ->
    undefined.

%% Use the ?IS_PORT guard macro from macros.hrl in a guard. Two clauses.
-spec is_port(term()) -> boolean().
is_port(P) ->
    undefined.

%% "retry 1 of 3" style label. Use ?MAX_RETRIES for the total.
-spec retry_label(pos_integer()) -> string().
retry_label(Attempt) ->
    undefined.

%% Return the given timeout, or ?DEFAULT_TIMEOUT when passed `default`.
-spec with_timeout(default | pos_integer()) -> pos_integer().
with_timeout(Timeout) ->
    undefined.

%% Return the -vsn attribute value. module_info(attributes) returns a
%% proplist like [{vsn, "1.2.0"}, {author, [erlanglings]}]. Attribute values
%% are stored as lists: a non-list value gets wrapped ([erlanglings]), while a
%% string is already a list and stays as it is.
-spec version() -> string().
version() ->
    undefined.
