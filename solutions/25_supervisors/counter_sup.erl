%%
%% A supervisor is a process whose only job is to start, watch and restart
%% other processes. Supervisor modules are tiny: start_link/0 plus an init/1
%% that returns a description of the children. All the behaviour is in OTP.
%%
%% When you read a supervisor, you are reading an org chart: WHO is started,
%% in WHAT order, and WHAT happens when one of them dies.
%%
-module(counter_sup).
-behaviour(supervisor).

%%% API
-export([start_link/0]).

%%% supervisor callbacks
-export([init/1]).

-spec start_link() -> {ok, pid()} | {error, term()}.
start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

%% init/1 must return:
%%
%%   {ok, {SupFlags, [ChildSpec]}}
%%
%% SupFlags is a map:
%%   #{strategy  => one_for_one,   % restart only the child that died
%%     intensity => 5,             % allow at most 5 restarts...
%%     period    => 10}            % ...per 10 seconds, else the sup itself dies
%%
%% Each ChildSpec is a map; see counter_worker:child_spec/0 for the fields.
%%
-spec init([]) -> {ok, {supervisor:sup_flags(), [supervisor:child_spec()]}}.
init([]) ->
    SupFlags = #{strategy => one_for_one,
                 intensity => 5,
                 period => 10},
    Children = [counter_worker:child_spec()],
    {ok, {SupFlags, Children}}.
