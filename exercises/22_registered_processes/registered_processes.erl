%% I AM NOT DONE
-module(registered_processes).

%% A counter server that is reached by NAME instead of by pid.
%%
%% Pids are awkward to pass around: whoever needs to talk to a long-lived
%% server would have to be handed its pid, and the pid changes every time the
%% server restarts. The process REGISTRY solves that:
%%
%%   register(Name, Pid)      give Pid the atom Name (one name per pid, one pid
%%                            per name; registering twice -> error:badarg)
%%   whereis(Name)            the pid, or `undefined` if nothing has that name
%%   Name ! Msg               send to the registered process. If no process has
%%                            that name: error:badarg (unlike Pid ! Msg, which
%%                            silently succeeds for dead pids)
%%   unregister(Name)         remove the name (also happens automatically when
%%                            the process dies)
%%   registered()             list of all registered names
%%
%% The overwhelmingly common idiom: a server registers itself under its own
%% module name, so ?MODULE is both "the code" and "the process":
%%
%%   start_link() -> gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).
%%   get()        -> gen_server:call(?MODULE, get).
%%
%% Name scopes you will read in production code:
%%   {local, Name}            this node's registry (the one above)
%%   {global, Name}           cluster-wide registry (the `global` module)
%%   {via, Module, Name}      a custom registry, e.g. gproc or pg
%%
%% Since only one process can hold a name, registered processes are
%% singletons on their node -- which is sometimes a bottleneck and often the
%% reason you see a pool of workers under a single registered manager.

-export([start/0, stop/0, increment/0, value/0, reset/0]).
-export([loop/1]).

%% Spawn the counter loop with initial value 0 and register the pid under
%% the name ?MODULE. Return the pid.
%% Starting a second one while the first is alive must fail with
%% {error, already_started} -- check whereis/1 first.
-spec start() -> pid() | {error, already_started}.
start() ->
    undefined.

%% Ask the registered counter to stop. Returns ok.
-spec stop() -> ok.
stop() ->
    undefined.

%% Add one to the counter and return the new value. Send to the NAME, not a
%% pid. Use the {From, Ref, Request} / {Ref, Reply} protocol from the
%% previous exercises (1000 ms timeout; exit({timeout, ?FUNCTION_NAME}) on
%% timeout).
-spec increment() -> pos_integer().
increment() ->
    undefined.

%% Current value.
-spec value() -> non_neg_integer().
value() ->
    undefined.

%% Set the counter back to 0. Returns ok.
-spec reset() -> ok.
reset() ->
    undefined.

%% The server loop. Requests: increment | value | reset | stop.
-spec loop(non_neg_integer()) -> ok.
loop(Count) ->
    undefined.
