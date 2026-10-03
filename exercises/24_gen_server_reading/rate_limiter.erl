%%%-------------------------------------------------------------------
%%% @doc Fixed-window rate limiter.
%%%
%%% Each key (a user id, an IP, a device...) gets `limit' tokens per
%%% window. `allow/2' consumes one token and returns `ok', or
%%% `{error, rate_limited}' once the bucket for that key is empty.
%%% Every `refill_ms' milliseconds all buckets are reset.
%%%
%%% This module is READ-ONLY for the exercise. Read it top to bottom,
%%% then answer the questions in rate_limiter_tests.erl.
%%% @end
%%%-------------------------------------------------------------------
-module(rate_limiter).
-behaviour(gen_server).

%%% API
-export([start_link/1, allow/2, remaining/2, reset/1, stop/1]).

%%% gen_server callbacks
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

-define(DEFAULT_LIMIT, 10).
-define(DEFAULT_REFILL_MS, 1000).

-type key() :: term().
-type opts() :: #{limit => pos_integer(), refill_ms => pos_integer()}.

-record(state, {
    limit     :: pos_integer(),                   % tokens per key per window
    refill_ms :: pos_integer(),                   % window length
    buckets = #{} :: #{key() => non_neg_integer()}, % tokens LEFT per key
    timer     :: reference() | undefined         % pending refill timer
}).

-type state() :: #state{}.

%%%===================================================================
%%% API
%%%===================================================================

%% Unlike kv_store, this server is NOT registered under a name: many
%% limiters may run at once (one per feature, say), so clients hold a pid.
-spec start_link(opts()) -> {ok, pid()} | {error, term()}.
start_link(Opts) when is_map(Opts) ->
    gen_server:start_link(?MODULE, Opts, []).

-spec allow(pid(), key()) -> ok | {error, rate_limited}.
allow(Pid, Key) ->
    gen_server:call(Pid, {allow, Key}).

-spec remaining(pid(), key()) -> non_neg_integer().
remaining(Pid, Key) ->
    gen_server:call(Pid, {remaining, Key}).

-spec reset(pid()) -> ok.
reset(Pid) ->
    gen_server:cast(Pid, reset).

-spec stop(pid()) -> ok.
stop(Pid) ->
    gen_server:stop(Pid).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================

-spec init(opts()) -> {ok, state()}.
init(Opts) ->
    Limit = maps:get(limit, Opts, ?DEFAULT_LIMIT),
    RefillMs = maps:get(refill_ms, Opts, ?DEFAULT_REFILL_MS),
    Timer = schedule_refill(RefillMs),
    {ok, #state{limit = Limit, refill_ms = RefillMs, timer = Timer}}.

-spec handle_call(term(), gen_server:from(), state()) ->
          {reply, term(), state()}.
handle_call({allow, Key}, _From, #state{buckets = Buckets} = State) ->
    case tokens_left(Key, State) of
        0 ->
            {reply, {error, rate_limited}, State};
        N ->
            NewBuckets = Buckets#{Key => N - 1},
            {reply, ok, State#state{buckets = NewBuckets}}
    end;
handle_call({remaining, Key}, _From, State) ->
    {reply, tokens_left(Key, State), State};
handle_call(Request, _From, State) ->
    {reply, {error, {unknown_call, Request}}, State}.

-spec handle_cast(term(), state()) -> {noreply, state()}.
handle_cast(reset, State) ->
    {noreply, State#state{buckets = #{}}};
handle_cast(_Msg, State) ->
    {noreply, State}.

%% The refill timer message arrives here, not in handle_call: it was sent
%% with plain `!' semantics by erlang:send_after/3.
-spec handle_info(term(), state()) -> {noreply, state()}.
handle_info(refill, #state{refill_ms = RefillMs} = State) ->
    Timer = schedule_refill(RefillMs),
    {noreply, State#state{buckets = #{}, timer = Timer}};
handle_info(_Info, State) ->
    {noreply, State}.

-spec terminate(term(), state()) -> ok.
terminate(_Reason, #state{timer = undefined}) ->
    ok;
terminate(_Reason, #state{timer = Timer}) ->
    _ = erlang:cancel_timer(Timer),
    ok.

-spec code_change(term(), state(), term()) -> {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================

%% A key that has never been seen has a full bucket. Storing only keys
%% that have been used keeps the map small.
-spec tokens_left(key(), state()) -> non_neg_integer().
tokens_left(Key, #state{limit = Limit, buckets = Buckets}) ->
    maps:get(Key, Buckets, Limit).

-spec schedule_refill(pos_integer()) -> reference().
schedule_refill(RefillMs) ->
    erlang:send_after(RefillMs, self(), refill).
