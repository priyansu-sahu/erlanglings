-module(crash_reasons_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% classify/1 runs a fun and returns {Class, Reason} for whatever it raises.
%% Class is one of the atoms error | exit | throw. Reason is the term you
%% would see after "** exception error:" in the shell, or in the `reason'
%% field of a crash report.
%%
%% For the ?assertMatch questions, write a PATTERN (you may use `_').

classify(Fun) ->
    try Fun() of
        Value -> {ok, Value}
    catch
        Class:Reason -> {Class, Reason}
    end.

%% The `error' class: bugs ----------------------------------------------

errors_test_() ->
    [
     %% Q1. {ok, Value} = {error, not_found}
     ?_assertEqual({error, {badmatch, {error, not_found}}},
                   classify(fun crash_reasons:badmatch/0)),

     %% Q2. only_atoms(42) where only_atoms has one clause guarded by
     %%     is_atom/1. (The reason is a bare atom: the arguments are in the
     %%     stack trace, not in the reason.)
     ?_assertEqual({error, function_clause}, classify(fun crash_reasons:function_clause/0)),

     %% Q3. `case 3 of 1 -> ...; 2 -> ... end'. The reason carries the value
     %%     that matched nothing.
     ?_assertEqual({error, {case_clause, 3}}, classify(fun crash_reasons:case_clause/0)),

     %% Q4. list_to_atom(42)
     ?_assertEqual({error, badarg}, classify(fun crash_reasons:badarg/0)),

     %% Q5. a + 1
     ?_assertEqual({error, badarith}, classify(fun crash_reasons:badarith/0)),

     %% Q6. definitely_missing_module:run()
     ?_assertEqual({error, undef}, classify(fun crash_reasons:undef/0)),

     %% Q7. maps:get(name, #{port => 80})
     ?_assertEqual({error, {badkey, name}}, classify(fun crash_reasons:badkey/0)),

     %% Q8. maps:get(port, not_a_map)
     ?_assertEqual({error, {badmap, not_a_map}}, classify(fun crash_reasons:badmap/0)),

     %% Q9. An `if' with no matching clause.
     ?_assertEqual({error, if_clause}, classify(fun crash_reasons:if_clause/0)),

     %% Q10. `try 1 of 10 -> ten catch ... end'. Is the `of' section
     %%      protected by the catch? What is raised?
     ?_assertEqual({error, {try_clause, 1}}, classify(fun crash_reasons:try_clause/0)),

     %% Q11. F = not_a_fun, F(1)
     ?_assertEqual({error, {badfun, not_a_fun}}, classify(fun crash_reasons:badfun/0)),

     %% Q12. Calling a one-argument fun with two arguments. The reason is
     %%      {badarity, {Fun, Args}}. Write a pattern with `_' for the fun.
     ?_assertMatch({error, {badarity, {_, [1, 2]}}}, classify(fun crash_reasons:badarity/0)),

     %% Q13. R#user.name where R is {person, 1}. The exact second element
     %%      differs between OTP versions, so use a pattern with `_'.
     ?_assertMatch({error, {badrecord, _}}, classify(fun crash_reasons:badrecord/0))
    ].

%% The `exit' class: process-level events ---------------------------------

exits_test_() ->
    [
     %% Q14. gen_server:call to a name nobody registered. Note the CLASS:
     %%      gen_server:call converts failures into exits, and the reason
     %%      is {noproc, {gen_server, call, Args}}. Pattern with `_' for Args.
     ?_assertMatch({exit, {noproc, {gen_server, call, _}}}, classify(fun crash_reasons:noproc/0)),

     %% Q15. gen_server:call that times out after 50 ms. Same shape, other
     %%      tag.
     ?_assertMatch({exit, {timeout, {gen_server, call, _}}}, classify(fun crash_reasons:timeout/0)),

     %% Q16. exit(shutdown)
     ?_assertEqual({exit, shutdown}, classify(fun crash_reasons:exit_shutdown/0))
    ].

%% The `throw' class: non-local return ------------------------------------

throws_test_() ->
    [
     %% Q17. throw({not_an_error, just_a_value})
     ?_assertEqual({throw, {not_an_error, just_a_value}}, classify(fun crash_reasons:throw_value/0))
    ].

%% Wrapping and stack traces ------------------------------------------------

wrapped_test_() ->
    [
     %% Q18. wrapped/0 catches the badmatch from badmatch/0 and raises
     %%      error({config_error, Reason}). What is the full reason now?
     ?_assertEqual({error, {config_error, {badmatch, {error, not_found}}}},
                   classify(fun crash_reasons:wrapped/0))
    ].

%% A stack trace is a list of frames, innermost first:
%%   {Module, Function, ArityOrArgs, [{file, "..."}, {line, N}]}
%% For most errors the third element is the ARITY. For function_clause and
%% badarg it is the actual ARGUMENT LIST, which is often the single most
%% useful thing in a crash report.
stacktrace_test_() ->
    [
     %% Q19. Which {Module, Function} is on top of the stack when badmatch/0
     %%      fails?
     fun() ->
         Top = try crash_reasons:badmatch()
               catch error:_:Stack -> hd(Stack)
               end,
         {M, F, _ArityOrArgs, _Location} = Top,
         ?assertEqual({crash_reasons, badmatch}, {M, F})
     end,

     %% Q20. When only_atoms/1 raises function_clause, what is the third
     %%      element of the top frame?
     fun() ->
         Top = try crash_reasons:function_clause()
               catch error:function_clause:Stack -> hd(Stack)
               end,
         {crash_reasons, only_atoms, ArityOrArgs, _Location} = Top,
         ?assertEqual([42], ArityOrArgs)
     end
    ].
