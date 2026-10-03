%% Record fields can carry types. Dialyzer checks them; the runtime does not.
-record(presence, {
    user_id :: pos_integer(),
    status  :: online | offline | {away, binary()},
    since   :: non_neg_integer()      % seconds since epoch
}).
