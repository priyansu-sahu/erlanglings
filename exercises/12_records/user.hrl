%% A record definition. In production code these almost always live in a
%% header file (.hrl) so several modules can share the same definition.
%%
%%   -record(Name, {Field1, Field2 = Default, Field3 :: type()}).
%%
%% Fields without a default get the atom `undefined` when not set.
-record(user, {
    id          :: pos_integer() | undefined,
    name        :: binary() | undefined,
    status = offline :: online | offline,
    devices = [] :: [binary()]
}).
