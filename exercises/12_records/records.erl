%% I AM NOT DONE
-module(records).

%% `-include("user.hrl").` pulls the record definition into this module at
%% compile time. In real codebases you will chase a LOT of `#name{}` usages
%% back to some .hrl file to find out what the fields are.
-include("user.hrl").

-export([new/2, go_online/1, is_online/1, add_device/2, name/1, to_map/1]).

%% Records are compile-time sugar over tagged tuples:
%%
%%   #user{id = 1, name = <<"ann">>}  is really  {user, 1, <<"ann">>, offline, []}
%%
%% so when you print one in the shell without the definition loaded you get
%% the raw tuple. The syntax to recognize:
%%
%%   #user{id = 1}             construct (missing fields take their defaults)
%%   U#user.name               read one field
%%   U#user{status = online}   copy U with one field changed (U is NOT mutated)
%%   #user{status = online}    as a PATTERN in a function head or case
%%   #user.status              the field's position in the tuple (an integer)
%%
%% Pattern matching on records in function heads is the dominant style:
%%
%%   handle(#user{status = online} = U) -> ...   % matches AND keeps the whole record as U

%% Create a user with the given id and name. Status and devices get defaults.
-spec new(pos_integer(), binary()) -> #user{}.
new(Id, Name) ->
    undefined.

%% Return a copy of the user with status set to online.
-spec go_online(#user{}) -> #user{}.
go_online(User) ->
    undefined.

%% true if the user's status is online. Write this with TWO clauses that
%% pattern match on the record -- no `case`, no `==`.
-spec is_online(#user{}) -> boolean().
is_online(User) ->
    undefined.

%% Prepend a device id to the user's devices list.
-spec add_device(#user{}, binary()) -> #user{}.
add_device(User, DeviceId) ->
    undefined.

%% Return the user's name.
-spec name(#user{}) -> binary().
name(User) ->
    undefined.

%% Convert to a map with keys id, name, status, devices.
-spec to_map(#user{}) -> map().
to_map(User) ->
    undefined.
