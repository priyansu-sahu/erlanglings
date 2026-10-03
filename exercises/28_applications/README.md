# Applications

An OTP *application* is the unit you deploy: a named bundle of modules, a
resource file describing them, configuration, and (usually) a supervision
tree that is started when the application starts. A running Erlang node is a
set of applications: `kernel`, `stdlib`, `ssl`, plus your own.

Reading an unfamiliar codebase starts here. Find the `.app.src` (or `.app`)
file, find its `mod` entry, open that module, follow `start/2` to the top
supervisor. That path is the table of contents for everything the system
runs.

## Reading notes

### The resource file

`demo_app.app` is a single Erlang term, read with `file:consult/1`:

```erlang
{application, demo_app,
 [{description, "..."},
  {vsn, "0.1.0"},
  {modules, [demo_app, demo_sup]},
  {registered, [demo_sup]},
  {applications, [kernel, stdlib]},   % must be started before this app
  {mod, {demo_app, []}},              % callback module and start args
  {env, [{port, 8080}]}]}.            % default configuration
```

In a rebar3 project you edit `src/demo_app.app.src`; the build copies it to
`ebin/demo_app.app`, filling in `modules` automatically. Key facts:

* **`applications`** lists dependencies. `application:ensure_all_started/1`
  walks this list and starts them in order. Missing a dependency here is a
  classic "works in the shell, fails in the release" bug.
* **`mod`** is optional. An application without it is a *library
  application*: just code, no processes (e.g. most parsing libraries).
* **`env`** is the default config. A release's `sys.config` overrides it,
  and `application:set_env/3` changes it at runtime. Code reads it with
  `application:get_env(App, Key, Default)`.

### The callback module

```erlang
-module(demo_app).
-behaviour(application).
-export([start/2, stop/1]).

start(_Type, _Args) -> demo_sup:start_link().
stop(_State) -> ok.
```

That is the whole module in most real applications. `start/2` **must return
`{ok, Pid}`** where `Pid` is the top supervisor; anything else makes
`application:start/1` fail with `{bad_return, ...}`.

### The start-up chain

```
application:start(demo_app)
  -> application controller reads demo_app.app
  -> checks every app in `applications` is running
  -> calls demo_app:start(normal, [])            % from {mod, {demo_app, []}}
     -> demo_sup:start_link()
        -> demo_sup:init([]) returns the child specs
           -> each child's start function runs, in order
  -> demo_app:start/2 returns {ok, SupPid}; the app is now "running"
```

`application:stop/1` reverses it: the supervisor tree is shut down, then
`stop/1` is called.

### Useful shell calls when reading a live system

| call | tells you |
|---|---|
| `application:which_applications()` | what is running: `[{Name, Description, Vsn}]` |
| `application:loaded_applications()` | loaded but maybe not started |
| `application:get_env(App, Key)` | `{ok, Value}` or `undefined` |
| `application:get_all_env(App)` | the whole env proplist |
| `application:get_key(App, Key)` | any key from the `.app` file |
| `application:ensure_all_started(App)` | start App and everything it depends on |

## Your task

1. In `demo_app.erl`, implement `start/2` so that it starts `demo_sup` and
   returns `{ok, Pid}`.
2. In `demo_app_tests.erl`, answer the reading questions by replacing each
   `?TODO`. Everything you need is in `demo_app.app`.

`demo_sup.erl` and `demo_app.app` are read-only.

## Run

```sh
./erlanglings run 28_applications
```

On Windows: `erlanglings run 28_applications`.

## Hints

<details><summary>Hints</summary>

* `start/2` is one line: `demo_sup:start_link().` It already returns
  `{ok, Pid}`.
* Q1: the tuple is `{demo_app, Description, Vsn}` with the exact strings
  from the `.app` file.
* Q2: `get_env/2` wraps the value in `{ok, _}`; a missing key is the bare
  atom `undefined`.
* Q4: `get_key/2` also wraps in `{ok, _}`.
* Q5: `{error, {already_started, demo_app}}`.

</details>
