# Fix the Punctuation

Three characters carry most of Erlang's structure: `,` `;` and `.`. Until they
are second nature, every function looks like a wall of symbols. This exercise
gives you a logically correct module whose separators are wrong, and asks you
to repair it by reading compiler errors.

## Reading notes

| Separator | Joins                                        | Read it as            |
|-----------|----------------------------------------------|-----------------------|
| `,`       | expressions in a body; elements in a list/tuple/args | "and then"      |
| `;`       | clauses of a function, `case`, `if`, `receive`, `try`, `fun` | "or, alternatively" |
| `.`       | ends a function definition or attribute      | "end of this top-level thing" |

The shape of a multi-clause function:

```erlang
area({square, S}) -> S * S;          % clause 1, ends with ;
area({rect, W, H}) -> W * H;         % clause 2, ends with ;
area({circle, R}) -> 3.14 * R * R.   % last clause, ends with .
```

The shape of a `case` (same for `if`, `receive`, `try`):

```erlang
case Reply of
    {ok, V} -> V;                    % alternative, ends with ;
    {error, _} -> default            % LAST alternative: nothing after it
end                                  % end closes it; then , ; or . follows
```

Reading `end`: whatever separator comes after `end` belongs to the *enclosing*
construct, not to the `case`. `end,` means more expressions follow in this
body. `end;` means another clause of the enclosing function follows. `end.`
means the function is over.

Compiler error patterns you will learn to recognise:

- `syntax error before: 'name'` on line N: usually the line *before* N ends
  with `.` or `;` where it should not, so the parser thinks a new function
  started.
- `head mismatch` : two adjacent clauses have different names or arities. The
  most common cause is a `.` instead of `;` between clauses, splitting one
  function into two with the same name.
- `syntax error before: 'end'`: a trailing `;` or `,` on the last alternative
  of a `case`/`if`/`receive`.
- `function f/1 already defined`: same root cause as head mismatch.

Guards in `case` and function heads use `when`, and inside a guard `,` means
"and" while `;` means "or". So punctuation is overloaded there; exercise 04.

## Your task

1. Run the exercise. Read the first compiler error, find the offending
   separator, fix it, run again. Repeat until the module compiles and the tests
   pass. Change only punctuation in `fix_the_punctuation.erl`.
2. Fill in the `?TODO` predictions in `fix_the_punctuation_tests.erl`.
3. Remove the `%% I AM NOT DONE` lines.

## Run

```sh
./erlanglings run 03_fix_the_punctuation
```

On Windows (cmd/PowerShell): `erlanglings run 03_fix_the_punctuation`

## Hints

<details><summary>Hints</summary>

- `describe/1` has three clauses. Clauses are joined with `;` and the whole
  function ends with `.`.
- In `classify/1`, the alternatives inside `case ... end` are joined with `;`
  and the last one has no separator before `end`.
- In `sum_pairs/1`, the body is three expressions that run one after another:
  join them with `,`.
- The value of a sequence of expressions is the value of the last one; the
  earlier ones are evaluated and thrown away.

</details>
