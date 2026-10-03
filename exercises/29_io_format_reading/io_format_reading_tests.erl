%% I AM NOT DONE
-module(io_format_reading_tests).

-include_lib("eunit/include/eunit.hrl").

-define(TODO, '__TODO__').

%% --- Reading: predict the result. Replace ?TODO with your answer. ---
%%
%% Every answer is a plain Erlang string (a list of characters), because
%% fmt/2 flattens the iolist that io_lib:format returns. Write your
%% predictions as string literals, e.g. "hello". Remember that a string
%% containing double quotes needs them escaped: "\"hello\"".

-import(io_format_reading, [fmt/2]).

%% ~p, ~s and ~w: the three ways to print a term ---------------------------

p_vs_s_vs_w_test_() ->
    [
     %% Q1. ~p pretty-prints a term as Erlang source. A string is a term,
     %%     so it comes back WITH its quotes.
     ?_assertEqual(?TODO, fmt("~p", ["hello"])),

     %% Q2. ~s prints a string/binary/atom as raw text, no quotes.
     ?_assertEqual(?TODO, fmt("~s", ["hello"])),

     %% Q3. ~w is like ~p but never guesses that a list is a string and
     %%     never adds line breaks. What are the character codes of "hi"?
     ?_assertEqual(?TODO, fmt("~w", ["hi"])),

     %% Q4. The famous gotcha in reverse: a list of small integers that
     %%     happens to be printable. ~p shows it as...?
     ?_assertEqual(?TODO, fmt("~p", [[104, 105]])),

     %% Q5. ~p of a binary.
     ?_assertEqual(?TODO, fmt("~p", [<<"hi">>])),

     %% Q6. ~w of the same binary: raw bytes.
     ?_assertEqual(?TODO, fmt("~w", [<<"hi">>])),

     %% Q7. ~s of a binary and of an atom.
     ?_assertEqual(?TODO, fmt("~s", [<<"hi">>])),
     ?_assertEqual(?TODO, fmt("~s", [ok])),

     %% Q8. ~s accepts an iolist too (nested lists of strings/binaries/chars).
     ?_assertEqual(?TODO, fmt("~s", [[<<"a">>, "b", $c]])),

     %% Q9. Atoms that need quoting are printed quoted by ~p.
     ?_assertEqual(?TODO, fmt("~p", ['Hello'])),

     %% Q10. Nested terms, the way they appear in crash logs.
     ?_assertEqual(?TODO, fmt("~p", [{error, {badmatch, [1, 2]}}])),

     %% Q11. Maps.
     ?_assertEqual(?TODO, fmt("~p", [#{a => 1}]))
    ].

%% Numbers --------------------------------------------------------------

numbers_test_() ->
    [
     %% Q12. ~b is an integer in base 10...
     ?_assertEqual(?TODO, fmt("~b", [255])),
     %% ...and ~.16b is base 16.
     ?_assertEqual(?TODO, fmt("~.16b", [255])),

     %% Q13. Floats: ~.2f is two decimals; ~8.2f is the same in a field of
     %%      width 8 (padded on the left with spaces).
     ?_assertEqual(?TODO, fmt("~.2f", [3.14159])),
     ?_assertEqual(?TODO, fmt("~8.2f", [3.14159])),

     %% Q14. ~f with no precision defaults to six decimals; ~p prints the
     %%      shortest representation that round-trips.
     ?_assertEqual(?TODO, fmt("~f", [1.0])),
     ?_assertEqual(?TODO, fmt("~p", [1.0]))
    ].

%% Padding, control characters, depth ---------------------------------------

layout_test_() ->
    [
     %% Q15. A field width pads on the LEFT by default (right-justified)...
     ?_assertEqual(?TODO, fmt("~10s|", ["hello"])),
     %% ...and a minus sign left-justifies.
     ?_assertEqual(?TODO, fmt("~-10s|", ["hello"])),

     %% Q16. ~n is a newline, ~~ is a literal tilde, ~c is a character.
     ?_assertEqual(?TODO, fmt("~p~n", [x])),
     ?_assertEqual(?TODO, fmt("~~", [])),
     ?_assertEqual(?TODO, fmt("~c", [$a])),

     %% Q17. ~P takes an extra DEPTH argument and elides the rest with
     %%      "|...". This is how loggers avoid printing huge terms.
     ?_assertEqual(?TODO, fmt("~P", [lists:seq(1, 100), 5]))
    ].

%% The helpers in io_format_reading.erl ------------------------------------

helpers_test_() ->
    [
     %% Q18. Read log_line/3.
     ?_assertEqual(?TODO, io_format_reading:log_line(info, "~b users", [3])),

     %% Q19. Read hex/1: two hex digits per byte, zero-padded.
     ?_assertEqual(?TODO, io_format_reading:hex(<<1, 255>>)),

     %% Q20. Read pad_id/1.
     ?_assertEqual(?TODO, io_format_reading:pad_id(42)),

     %% Q21. Read describe_user/1.
     ?_assertEqual(?TODO, io_format_reading:describe_user(
                            #{name => <<"alice">>, devices => [a, b]})),

     %% Q22. Too few arguments for the format string. Which exception
     %%      (the Reason, for ?assertError) does io_lib:format raise?
     %%      This is one of the most common causes of a crashing log line.
     ?_assertError(?TODO, fmt("~p ~p", [only_one]))
    ].
