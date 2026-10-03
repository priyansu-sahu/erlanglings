%%
%% A gen_server is the workhorse of OTP. Almost every long-lived process in a
%% production Erlang system is one. Once you can read a gen_server quickly you
%% can read most of a codebase.
%%
%% The shape is always the same, and reading it is a two-column exercise:
%%
%%   LEFT column: the API (plain functions other modules call).
%%     put(K, V) -> gen_server:call(?MODULE, {put, K, V}).
%%
%%   RIGHT column: the callbacks (run INSIDE the server process).
%%     handle_call({put, K, V}, _From, State) -> {reply, ok, NewState}.
%%
%% The message term built by the API ({put, K, V}) is the thing you pattern
%% match on in the callback. To find out "what does put/2 actually do", you
%% jump from the API function to the handle_call clause with the same shape.
%%
%% Return values from callbacks are TAGGED TUPLES that tell gen_server what to
%% do next:
%%   {reply, Reply, NewState}   send Reply to the caller, keep running
%%   {noreply, NewState}        keep running, don't reply (casts, infos)
%%   {stop, Reason, NewState}   shut the server down
%%
-module(kv_store).
-behaviour(gen_server).

%%% ------------------------------------------------------------------
%%% API
%%% ------------------------------------------------------------------
-export([start_link/0, stop/0, put/2, get/1, delete/1, size/0]).

%%% ------------------------------------------------------------------
%%% gen_server callbacks
%%% ------------------------------------------------------------------
-export([init/1, handle_call/3, handle_cast/2, handle_info/2,
         terminate/2, code_change/3]).

%% The server's state. Here it is just a map, but production servers almost
%% always use a -record(state, {...}) -- see exercise 24.
-type state() :: #{term() => term()}.

%%% ------------------------------------------------------------------
%%% API -- these run in the CALLER's process
%%% ------------------------------------------------------------------

%% `{local, ?MODULE}` registers the process under the module name, so clients
%% can address it as `kv_store` without knowing its pid. Very common.
-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

-spec stop() -> ok.
stop() ->
    gen_server:stop(?MODULE).

%% `call` is synchronous: the caller blocks until handle_call replies
%% (default timeout: 5000 ms).
-spec put(term(), term()) -> ok.
put(Key, Value) ->
    gen_server:call(?MODULE, {put, Key, Value}).

-spec get(term()) -> {ok, term()} | {error, not_found}.
get(Key) ->
    gen_server:call(?MODULE, {get, Key}).

%% `cast` is asynchronous: fire and forget, returns `ok` immediately.
-spec delete(term()) -> ok.
delete(Key) ->
    gen_server:cast(?MODULE, {delete, Key}).

-spec size() -> non_neg_integer().
size() ->
    gen_server:call(?MODULE, size).

%%% ------------------------------------------------------------------
%%% gen_server callbacks -- these run INSIDE the server process
%%% ------------------------------------------------------------------

%% init/1 receives the third argument of start_link (here `[]`).
%% It must return {ok, InitialState}.
-spec init([]) -> {ok, state()}.
init([]) ->
    {ok, #{}}.

%% A production server never crashes on an unknown request; the final
%% catch-all clause replies with an error instead.
-spec handle_call(term(), gen_server:from(), state()) ->
          {reply, term(), state()}.
handle_call({put, Key, Value}, _From, State) ->
    {reply, ok, State#{Key => Value}};
handle_call({get, Key}, _From, State) ->
    Reply = case maps:find(Key, State) of
                {ok, Value} -> {ok, Value};
                error -> {error, not_found}
            end,
    {reply, Reply, State};
handle_call(size, _From, State) ->
    {reply, maps:size(State), State};
handle_call(Request, _From, State) ->
    {reply, {error, {unknown_call, Request}}, State}.

%% Casts never reply: return {noreply, NewState}.
-spec handle_cast(term(), state()) -> {noreply, state()}.
handle_cast({delete, Key}, State) ->
    {noreply, maps:remove(Key, State)};
handle_cast(_Msg, State) ->
    {noreply, State}.

%% handle_info receives any message that is NOT a call or a cast: raw `!`
%% sends, timer messages, monitor 'DOWN' messages, and so on.
-spec handle_info(term(), state()) -> {noreply, state()}.
handle_info(_Info, State) ->
    {noreply, State}.

%% Called when the server is about to exit. Clean-up goes here.
-spec terminate(term(), state()) -> ok.
terminate(_Reason, _State) ->
    ok.

%% Called during a hot code upgrade. Almost always just returns the state.
-spec code_change(term(), state(), term()) -> {ok, state()}.
code_change(_OldVsn, State, _Extra) ->
    {ok, State}.
