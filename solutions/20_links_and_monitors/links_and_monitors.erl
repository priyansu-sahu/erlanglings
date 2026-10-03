-module(links_and_monitors).

-export([run_and_wait/1, exit_reason_via_link/1, supervise_once/1]).

-spec run_and_wait(fun(() -> term())) -> {ok, normal} | {crashed, term()}.
run_and_wait(Fun) ->
    {Pid, Ref} = spawn_monitor(Fun),
    receive
        {'DOWN', Ref, process, Pid, normal} -> {ok, normal};
        {'DOWN', Ref, process, Pid, Reason} -> {crashed, Reason}
    end.

-spec exit_reason_via_link(fun(() -> term())) -> term().
exit_reason_via_link(Fun) ->
    OldFlag = process_flag(trap_exit, true),
    Pid = spawn_link(Fun),
    receive
        {'EXIT', Pid, Reason} ->
            process_flag(trap_exit, OldFlag),
            Reason
    end.

-spec supervise_once(fun(() -> term())) ->
          {ok, first_try} | {ok, retried} | {error, gave_up, term()}.
supervise_once(Fun) ->
    case run_and_wait(Fun) of
        {ok, normal} ->
            {ok, first_try};
        {crashed, _FirstReason} ->
            case run_and_wait(Fun) of
                {ok, normal} -> {ok, retried};
                {crashed, Reason} -> {error, gave_up, Reason}
            end
    end.
