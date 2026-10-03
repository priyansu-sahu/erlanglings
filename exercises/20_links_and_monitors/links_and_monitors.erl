%% I AM NOT DONE
-module(links_and_monitors).

-export([run_and_wait/1, exit_reason_via_link/1, supervise_once/1]).

%% Processes die. Links and monitors are how OTHER processes find out.
%%
%% LINK (bidirectional, "we live and die together"):
%%   link(Pid) / spawn_link(Fun)
%%   If either side exits abnormally (reason =/= normal), the other gets an
%%   EXIT SIGNAL and dies too -- unless it is trapping exits:
%%       process_flag(trap_exit, true)
%%   in which case the signal becomes a plain message in its mailbox:
%%       {'EXIT', Pid, Reason}
%%   This is how supervisors work: they trap exits from their linked children.
%%
%% MONITOR (unidirectional, "tell me when it dies"):
%%   Ref = monitor(process, Pid)   or   {Pid, Ref} = spawn_monitor(Fun)
%%   When Pid dies, the monitoring process receives ONE message:
%%       {'DOWN', Ref, process, Pid, Reason}
%%   The watcher never dies because of the watched process. Monitoring an
%%   already-dead pid delivers a 'DOWN' with reason `noproc` immediately.
%%   demonitor(Ref, [flush]) removes the monitor and any pending 'DOWN' message.
%%
%% EXIT REASONS you will read in logs:
%%   normal        the function returned (or exit(normal)). Linked processes
%%                 are NOT killed by this.
%%   shutdown / {shutdown, Term}   a supervisor asked it to stop. Quiet.
%%   killed        exit(Pid, kill) was used -- the untrappable, "brutal" kill.
%%   anything else a crash: {badarith, Stack}, {{badmatch, V}, Stack}, ...
%%                 Logged as a crash report.
%%
%% exit/2 is NOT an exception: exit(Pid, Reason) sends an exit SIGNAL to Pid.
%% exit/1 raises an exit exception in the current process.

%% Spawn Fun with a monitor and wait for it to finish.
%% Return {ok, normal} if it returned normally, otherwise {crashed, Reason}.
%% Use ?assertMatch-friendly shapes: Reason is whatever 'DOWN' carried.
-spec run_and_wait(fun(() -> term())) -> {ok, normal} | {crashed, term()}.
run_and_wait(Fun) ->
    undefined.

%% Spawn Fun LINKED to the caller, trap exits, and return the exit reason that
%% arrives as an {'EXIT', Pid, Reason} message. Restore the trap_exit flag to
%% its previous value before returning (process_flag/2 returns the old value).
-spec exit_reason_via_link(fun(() -> term())) -> term().
exit_reason_via_link(Fun) ->
    undefined.

%% A one-shot supervisor. Spawn Fun under a monitor. If it exits with reason
%% `normal`, return {ok, first_try}. If it crashes, spawn it ONE more time;
%% return {ok, retried} if the second run exits normally, or
%% {error, gave_up, Reason} with the second crash reason.
-spec supervise_once(fun(() -> term())) ->
          {ok, first_try} | {ok, retried} | {error, gave_up, term()}.
supervise_once(Fun) ->
    undefined.
