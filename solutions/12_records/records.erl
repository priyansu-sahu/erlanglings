-module(records).

-include("user.hrl").

-export([new/2, go_online/1, is_online/1, add_device/2, name/1, to_map/1]).

-spec new(pos_integer(), binary()) -> #user{}.
new(Id, Name) ->
    #user{id = Id, name = Name}.

-spec go_online(#user{}) -> #user{}.
go_online(User) ->
    User#user{status = online}.

-spec is_online(#user{}) -> boolean().
is_online(#user{status = online}) -> true;
is_online(#user{}) -> false.

-spec add_device(#user{}, binary()) -> #user{}.
add_device(#user{devices = Devices} = User, DeviceId) ->
    User#user{devices = [DeviceId | Devices]}.

-spec name(#user{}) -> binary().
name(#user{name = Name}) ->
    Name.

-spec to_map(#user{}) -> map().
to_map(#user{id = Id, name = Name, status = Status, devices = Devices}) ->
    #{id => Id, name => Name, status => Status, devices => Devices}.
