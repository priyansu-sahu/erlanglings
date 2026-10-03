%% I AM NOT DONE
%%
%% An OTP *application* is the unit of packaging and start-up: a set of
%% modules, a resource file (demo_app.app) describing them, and optionally
%% a callback module like this one whose start/2 boots the top supervisor.
%%
%% When you read a codebase, the <name>_app.erl module is almost always
%% tiny and almost always looks exactly like this. It is the entry point:
%% start here, follow start/2 to the top supervisor, follow the supervisor
%% to the workers, and you have the whole process tree.
%%
%% The start-up chain is:
%%
%%   application:start(demo_app)
%%     -> reads demo_app.app, finds {mod, {demo_app, []}}
%%     -> calls demo_app:start(normal, [])
%%        -> which calls demo_sup:start_link()
%%        -> and must return {ok, SupervisorPid}
%%
-module(demo_app).
-behaviour(application).

-export([start/2, stop/1]).

%% StartType is `normal' except in distributed takeover/failover setups.
%% StartArgs is the second element of the `mod' tuple in the .app file.
%%
%% TODO: start the top supervisor and return {ok, Pid}.
-spec start(application:start_type(), term()) -> {ok, pid()} | {error, term()}.
start(_StartType, _StartArgs) ->
    undefined.

%% Called after the application has been stopped (the supervisor tree is
%% already down). Nearly always just `ok'.
-spec stop(term()) -> ok.
stop(_State) ->
    ok.
