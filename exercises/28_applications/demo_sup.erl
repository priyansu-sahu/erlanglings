%%%-------------------------------------------------------------------
%%% @doc Top-level supervisor of demo_app. READ-ONLY for this exercise.
%%%
%%% It has no children: the point of the exercise is the application
%%% plumbing, not the tree. In a real application this is where the
%%% workers would be listed.
%%% @end
%%%-------------------------------------------------------------------
-module(demo_sup).
-behaviour(supervisor).

%%% API
-export([start_link/0]).

%%% supervisor callbacks
-export([init/1]).

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    SupFlags = #{strategy => one_for_one, intensity => 5, period => 10},
    {ok, {SupFlags, []}}.
