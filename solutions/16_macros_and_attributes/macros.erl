-module(macros).

-vsn("1.2.0").
-author(erlanglings).

-include("macros.hrl").

-export([max_retries/0, module_name/0, module_string/0, where_am_i/0,
         is_port/1, retry_label/1, with_timeout/1, version/0]).

-define(DEFAULT_TIMEOUT, 5000).

-spec max_retries() -> pos_integer().
max_retries() ->
    ?MAX_RETRIES.

-spec module_name() -> atom().
module_name() ->
    ?MODULE.

-spec module_string() -> string().
module_string() ->
    ?MODULE_STRING.

-spec where_am_i() -> {atom(), non_neg_integer()}.
where_am_i() ->
    {?FUNCTION_NAME, ?FUNCTION_ARITY}.

-spec is_port(term()) -> boolean().
is_port(P) when ?IS_PORT(P) -> true;
is_port(_) -> false.

-spec retry_label(pos_integer()) -> string().
retry_label(Attempt) ->
    "retry " ++ integer_to_list(Attempt) ++ " of " ++ integer_to_list(?MAX_RETRIES).

-spec with_timeout(default | pos_integer()) -> pos_integer().
with_timeout(default) -> ?DEFAULT_TIMEOUT;
with_timeout(Timeout) -> Timeout.

-spec version() -> string().
version() ->
    {vsn, Vsn} = lists:keyfind(vsn, 1, ?MODULE:module_info(attributes)),
    Vsn.
