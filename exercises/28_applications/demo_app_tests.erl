%% I AM NOT DONE
-module(demo_app_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% Load the application spec straight from demo_app.app in this directory.
%% ?FILE is the path of THIS source file, so filename:dirname(?FILE) is the
%% exercise directory. (Normally the .app lives in ebin/ on the code path
%% and application:load(demo_app) finds it by itself.)
load() ->
    AppFile = filename:join(filename:dirname(?FILE), "demo_app.app"),
    {ok, [AppSpec]} = file:consult(AppFile),
    case application:load(AppSpec) of
        ok -> ok;
        {error, {already_loaded, demo_app}} -> ok
    end.

unload(_) ->
    _ = application:stop(demo_app),
    _ = application:unload(demo_app),
    ok.

demo_app_test_() ->
    {setup, fun load/0, fun unload/1,
     [
      fun start_runs_the_supervisor/0,
      fun reading_questions/0
     ]}.

start_runs_the_supervisor() ->
    ?assertEqual(ok, application:start(demo_app)),
    ?assert(is_pid(whereis(demo_sup))),
    ok = application:stop(demo_app),
    ?assertEqual(undefined, whereis(demo_sup)).

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%% All answers can be read off demo_app.app and the application docs.
reading_questions() ->
    ok = application:start(demo_app),

    %% Q1. application:which_applications/0 lists running apps as
    %%     {Name, Description, Vsn} tuples. What is the demo_app entry?
    ?assertEqual(?TODO,
                 lists:keyfind(demo_app, 1, application:which_applications())),

    %% Q2. Reading configuration. get_env/2 returns {ok, Value} or undefined.
    ?assertEqual(?TODO, application:get_env(demo_app, port)),
    ?assertEqual(?TODO, application:get_env(demo_app, timeout)),

    %% Q3. get_env/3 takes a default. (This is the form you see most in code.)
    ?assertEqual(?TODO, application:get_env(demo_app, timeout, 5000)),

    %% Q4. get_key/2 reads any key of the .app file.
    ?assertEqual(?TODO, application:get_key(demo_app, vsn)),
    ?assertEqual(?TODO, application:get_key(demo_app, mod)),

    %% Q5. Starting an application that is already running.
    ?assertEqual(?TODO, application:start(demo_app)),

    %% Q6. Setting env at runtime (common in tests and in sys.config-less
    %%     deployments). What does get_env return afterwards?
    ok = application:set_env(demo_app, port, 9090),
    ?assertEqual(?TODO, application:get_env(demo_app, port)),

    ok = application:stop(demo_app).
