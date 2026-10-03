-module(type_specs).

-export([describe/1, find/2, online_ids/1, parse_status/1, summarize/1,
         pick/2, ensure_binary/1]).

-export_type([user_id/0, status/0, presence/0]).

-type user_id() :: pos_integer().
-type status()  :: online | offline | {away, Reason :: binary()}.

-include("presence.hrl").
-type presence() :: #presence{}.

-spec describe(status()) -> binary().
describe(online) -> <<"online">>;
describe(offline) -> <<"offline">>;
describe({away, Reason}) -> <<"away: ", Reason/binary>>.

-spec find(user_id(), [presence()]) -> {ok, presence()} | {error, not_found}.
find(UserId, Presences) ->
    case lists:keyfind(UserId, #presence.user_id, Presences) of
        #presence{} = P -> {ok, P};
        false -> {error, not_found}
    end.

-spec online_ids([presence()]) -> [user_id()].
online_ids(Presences) ->
    [Id || #presence{user_id = Id, status = online} <- Presences].

-spec parse_status(binary()) -> {ok, status()} | {error, {unknown_status, binary()}}.
parse_status(<<"online">>) -> {ok, online};
parse_status(<<"offline">>) -> {ok, offline};
parse_status(<<"away:", Reason/binary>>) -> {ok, {away, Reason}};
parse_status(Other) -> {error, {unknown_status, Other}}.

-spec summarize([presence()]) -> #{total := non_neg_integer(),
                                   online := non_neg_integer(),
                                   away := non_neg_integer()}.
summarize(Presences) ->
    lists:foldl(fun(#presence{status = online}, Acc) ->
                        maps:update_with(online, fun(N) -> N + 1 end, Acc);
                   (#presence{status = {away, _}}, Acc) ->
                        maps:update_with(away, fun(N) -> N + 1 end, Acc);
                   (#presence{}, Acc) ->
                        Acc
                end,
                #{total => length(Presences), online => 0, away => 0},
                Presences).

-spec pick(Key, Opts) -> Value when
      Key   :: atom(),
      Opts  :: [{atom(), term()}],
      Value :: term() | undefined.
pick(Key, Opts) ->
    proplists:get_value(Key, Opts).

-spec ensure_binary(iodata() | atom()) -> binary().
ensure_binary(Bin) when is_binary(Bin) -> Bin;
ensure_binary(Atom) when is_atom(Atom) -> atom_to_binary(Atom);
ensure_binary(IoData) -> iolist_to_binary(IoData).
