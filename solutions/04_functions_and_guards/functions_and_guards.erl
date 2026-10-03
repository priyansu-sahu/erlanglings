-module(functions_and_guards).

-export([sign/1, grade/1, describe/1, clamp/3, safe_div/2]).

%% A function with several clauses is Erlang's if/else chain. Clauses are
%% tried top to bottom; the first whose patterns match AND whose guard is
%% true runs. If none match: function_clause error.
%%
%%   f(0)                 -> zero;          literal pattern
%%   f(N) when N < 0      -> negative;      pattern + guard
%%   f(N) when N rem 2 =:= 0, N > 100 -> big_even;   comma = AND
%%   f(N) when is_float(N); is_atom(N) -> weird;     semicolon = OR
%%   f(_)                 -> other.         catch-all
%%
%% Guards are deliberately restricted. Allowed:
%%   - comparisons:           =:=  =/=  ==  /=  <  >  =<  >=
%%   - arithmetic/bit ops:    +  -  *  div  rem  band  bor  bsl ...
%%   - boolean connectives:   and  or  not  andalso  orelse  ,  ;
%%   - type tests:            is_integer/1 is_atom/1 is_list/1 is_binary/1
%%                            is_map/1 is_tuple/1 is_pid/1 is_function/1 ...
%%   - a few BIFs:            length/1 tuple_size/1 byte_size/1 map_size/1
%%                            element/2 hd/1 tl/1 abs/1 map_get/2 ...
%% NOT allowed: your own functions, or anything that could have side effects.
%% This is what makes a guard safe to evaluate speculatively.
%%
%% A guard that raises an exception (e.g. length(Atom)) does not crash; it
%% simply counts as false and the next clause is tried. Readers often miss
%% this: `when length(L) > 2` on a non-list quietly fails the guard.
%%
%% Note `=<` is less-or-equal (not `<=`), and `=/=` is not-exactly-equal.

%% TODO: return the atom negative, zero or positive.
sign(N) when N < 0 ->
    negative;
sign(0) ->
    zero;
sign(_) ->
    positive.

%% TODO: map a score 0..100 to a letter grade.
%%   >= 90 -> a,  >= 80 -> b,  >= 70 -> c,  otherwise -> f
grade(Score) when Score >= 90 ->
    a;
grade(Score) when Score >= 80 ->
    b;
grade(Score) when Score >= 70 ->
    c;
grade(_) ->
    f.

%% TODO: describe a term by type, using type-test guards:
%%   integers -> integer, floats -> float, atoms -> atom,
%%   binaries -> binary, lists -> list, anything else -> other.
%% Hint: one clause per type.
describe(T) when is_integer(T) ->
    integer;
describe(T) when is_float(T) ->
    float;
describe(T) when is_atom(T) ->
    atom;
describe(T) when is_binary(T) ->
    binary;
describe(T) when is_list(T) ->
    list;
describe(_) ->
    other.

%% TODO: clamp(Value, Min, Max) returns Value limited to the range [Min, Max].
clamp(Value, Min, _Max) when Value < Min ->
    Min;
clamp(Value, _Min, Max) when Value > Max ->
    Max;
clamp(Value, _Min, _Max) ->
    Value.

%% TODO: return {ok, A div B}, or {error, division_by_zero} when B is 0.
%% Use a guard, not an if.
safe_div(_A, 0) ->
    {error, division_by_zero};
safe_div(A, B) ->
    {ok, A div B}.
