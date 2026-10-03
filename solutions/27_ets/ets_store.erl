%%
%% ETS (Erlang Term Storage) is the in-memory table that production Erlang
%% systems lean on for anything that must be shared between processes or
%% survive a worker's crash: caches, registries, counters, session tables.
%%
%% Things to know when you see ETS in code:
%%
%%   * A table is created with ets:new(Name, Options) and OWNED by the
%%     process that created it. When the owner dies, the table is deleted.
%%     That is why tables are usually created in a long-lived gen_server's
%%     init/1 (or in a supervisor-started "table owner" process).
%%   * Rows are tuples. By default the KEY is the first element (keypos 1).
%%   * Table types: set (one row per key), ordered_set (sorted by key),
%%     bag (many rows per key, no duplicates), duplicate_bag.
%%   * ets:lookup/2 ALWAYS returns a list, even for a set: [] or [Row].
%%   * `named_table' lets you refer to the table by its atom name instead of
%%     the table id; `public' lets any process write to it.
%%
-module(ets_store).

-export([new/0, put/3, get/2, incr/2, keys/1, delete/2, older_than/2]).

%% The option `{read_concurrency, true}' is a common sight in real code; it
%% tunes the table for many readers and few writers.
-spec new() -> ets:tid().
new() ->
    ets:new(?MODULE, [set, public, {read_concurrency, true}]).

%% Store Value under Key, replacing any existing row for Key.
-spec put(ets:tid(), term(), term()) -> ok.
put(Tab, Key, Value) ->
    true = ets:insert(Tab, {Key, Value}),
    ok.

%% {ok, Value} if the key exists, otherwise not_found.
%% Remember: ets:lookup/2 returns a LIST of rows.
-spec get(ets:tid(), term()) -> {ok, term()} | not_found.
get(Tab, Key) ->
    case ets:lookup(Tab, Key) of
        [{Key, Value}] -> {ok, Value};
        [] -> not_found
    end.

%% Atomically add 1 to the integer stored under Key and return the new
%% value. If the key does not exist, treat it as 0 first.
%% Look at ets:update_counter/4: the 4th argument is a DEFAULT ROW to insert
%% when the key is missing, e.g. {Key, 0}.
-spec incr(ets:tid(), term()) -> integer().
incr(Tab, Key) ->
    ets:update_counter(Tab, Key, 1, {Key, 0}).

%% All keys in the table, sorted. Rows are {Key, Value}.
%% Any approach works: ets:foldl/3, ets:select/2 or ets:match/2 ... but
%% note that ets:match/2 wraps each result in a list (see the tests).
-spec keys(ets:tid()) -> [term()].
keys(Tab) ->
    lists:sort(ets:select(Tab, [{{'$1', '_'}, [], ['$1']}])).

-spec delete(ets:tid(), term()) -> ok.
delete(Tab, Key) ->
    true = ets:delete(Tab, Key),
    ok.

%% The table holds rows {Id, TimestampMs}. Return the Ids whose timestamp
%% is strictly less than Cutoff, sorted.
%%
%% Use a MATCH SPECIFICATION with ets:select/2. Match specs look odd but
%% appear all over production code (ets:select, dbg, recon). The shape is:
%%
%%   [{ MatchHead, [Guard, ...], [Result] }]
%%
%%   MatchHead: a row pattern where '$1', '$2'... are variables and '_' is a
%%              wildcard.                       e.g. {'$1', '$2'}
%%   Guards:    conditions written as tuples    e.g. {'<', '$2', Cutoff}
%%   Result:    what to return per matched row  e.g. '$1'
%%
%% So "give me Id for every {Id, Ts} with Ts < Cutoff" is:
%%
%%   ets:select(Tab, [{{'$1', '$2'}, [{'<', '$2', Cutoff}], ['$1']}])
%%
-spec older_than(ets:tid(), integer()) -> [term()].
older_than(Tab, Cutoff) ->
    MatchSpec = [{{'$1', '$2'}, [{'<', '$2', Cutoff}], ['$1']}],
    lists:sort(ets:select(Tab, MatchSpec)).
