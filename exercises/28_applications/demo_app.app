%% An application resource file. In a rebar3 project this is generated from
%% src/<name>.app.src and ends up in ebin/<name>.app. It is a single Erlang
%% term (note the full stop at the very end) and is read with file:consult/1.
{application, demo_app,
 [{description, "Demo application for erlanglings"},
  {vsn, "0.1.0"},
  %% Every module that belongs to this application (used by releases).
  {modules, [demo_app, demo_sup]},
  %% Registered process names this app owns. Prevents two apps from clashing.
  {registered, [demo_sup]},
  %% Applications that must be running BEFORE this one starts.
  {applications, [kernel, stdlib]},
  %% The application callback module and the argument passed to start/2.
  %% Library applications (no processes) simply have no `mod' key.
  {mod, {demo_app, []}},
  %% Configuration, readable with application:get_env/2,3. Overridden by
  %% sys.config in a release.
  {env, [{port, 8080},
         {max_sessions, 1000}]}
 ]}.
