%% I AM NOT DONE
-module(type_specs).

%% Specs and types are OPTIONAL annotations. The runtime ignores them; the
%% compiler only checks their syntax. Dialyzer (a static analysis tool) uses
%% them to find type errors, and -- more importantly for you -- they are the
%% best documentation a module has. Learn to read a spec and you can use a
%% function without reading its body.
%%
%% Anatomy:
%%
%%   -type user_id() :: pos_integer().
%%         ^name       ^definition. Types are written like function calls.
%%
%%   -spec find(user_id(), [#presence{}]) -> {ok, #presence{}} | {error, not_found}.
%%          ^fun  ^arg types               ^return type, `|` means "or"
%%
%%   -spec f(Key, Map) -> Value when Key :: atom(), Map :: map(), Value :: term().
%%          named args + `when` constraints: common in OTP docs.
%%
%% Built-in types you will see constantly:
%%   term() / any()      anything              atom()         an atom
%%   integer()           any integer           pos_integer()  1, 2, 3...
%%   non_neg_integer()   0, 1, 2...            neg_integer()  -1, -2...
%%   boolean()           true | false          binary()       <<...>>
%%   string()            [char()] -- a charlist, NOT a binary
%%   iodata()            binary() | iolist()   list() / [T]   list, list of T
%%   tuple()             any tuple             map()          any map
%%   pid()  reference()  fun()                 timeout()      non_neg_integer() | infinity
%%   #{K => V}           map with those keys   {a, b}         a 2-tuple of exactly a and b
%%   fun((A) -> B)       a 1-arity fun         ok | {error, term()}   a union of literals
%%   module() | mfa()    atom() | {module(), atom(), arity()}
%%
%% `-export_type([user_id/0]).` lets other modules write type_specs:user_id().
%% `-opaque` is like -type but outside modules may not look inside the value.

-export([describe/1, find/2, online_ids/1, parse_status/1, summarize/1,
         pick/2, ensure_binary/1]).

-export_type([user_id/0, status/0, presence/0]).

-type user_id() :: pos_integer().
-type status()  :: online | offline | {away, Reason :: binary()}.

%% The record lives in a header so the test module can build #presence{} too.
-include("presence.hrl").
-type presence() :: #presence{}.

%% Read the spec; the body must return a binary for EACH shape of status().
%% online -> <<"online">>, offline -> <<"offline">>,
%% {away, Reason} -> <<"away: ", Reason/binary>>
-spec describe(status()) -> binary().
describe(Status) ->
    undefined.

%% Read the spec: find the presence record for a user id, or report not_found.
-spec find(user_id(), [presence()]) -> {ok, presence()} | {error, not_found}.
find(UserId, Presences) ->
    undefined.

%% Read the spec: ids of everyone whose status is exactly `online`, in the
%% order given.
-spec online_ids([presence()]) -> [user_id()].
online_ids(Presences) ->
    undefined.

%% Parse a status binary: <<"online">>, <<"offline">>, or <<"away:", Reason>>
%% (anything after "away:" is the reason). Other input is an error whose
%% reason carries the unknown input -- read the spec for the exact shape.
-spec parse_status(binary()) -> {ok, status()} | {error, {unknown_status, binary()}}.
parse_status(Bin) ->
    undefined.

%% Produce a map with exactly the keys described in the spec. `:=` in a map
%% TYPE means the key is mandatory; `=>` means optional.
-spec summarize([presence()]) -> #{total := non_neg_integer(),
                                   online := non_neg_integer(),
                                   away := non_neg_integer()}.
summarize(Presences) ->
    undefined.

%% The spec with named arguments and a `when` clause. Returns the value for
%% Key in Opts (a proplist) or Default. proplists:get_value/3 does this.
-spec pick(Key, Opts) -> Value when
      Key   :: atom(),
      Opts  :: [{atom(), term()}],
      Value :: term() | undefined.
pick(Key, Opts) ->
    undefined.

%% iodata() | atom() in, binary() out. Three clauses: binary stays as-is,
%% atom via atom_to_binary/1, anything else via iolist_to_binary/1.
-spec ensure_binary(iodata() | atom()) -> binary().
ensure_binary(Value) ->
    undefined.
