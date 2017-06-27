%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 22. 六月 2017 下午2:45
%%%-------------------------------------------------------------------
-module(room_base).
-author("cyy").
-define(PDict, room_base).

%% API
-export([
  create/1,
  join/1,
  leave/1
]).

%%% players => [#{uid => 1, logo => 2, name => 3}]
%%% owner => int()
%%% room_info => map()
%%% ready => []
create(#{player := PlayerInfo, room_id := _RoomId, room_info := RoomInfo}) ->
  #{uid := Uid} = PlayerInfo,
  down(#{players => [PlayerInfo#{index => 1, owner => 1}], owner => Uid, room_info => RoomInfo, num => 1, ready => []}).

join(Player) ->
  #{players := Players, num := Num} = Room = load(),
  if
    Num == 5 -> {error, full};     %%满人
    true ->
      down(Room#{players => Players ++ [Player], num => Num + 1}),
      multi_cast(Players, {exec, {mod_room, new_player, Player}})
  end.

leave(Uid) ->
  #{players := Players, num := Num} = Room = load(),
  {NewPlayers, F} = lists:foldl(fun(Player, {NPlayers, Flag}) ->
    #{index := Index, uid := PlayerUid} = Player,
    if
      Uid == PlayerUid -> {NPlayers, 1};
      true -> {NPlayers ++ [Player#{index => Index - Flag}]}
    end end, {[], 0}, Players),
  down(Room#{players => NewPlayers, num => Num - F}),
  multi_cast(NewPlayers, {exec, {mod_room, player_leave, [Uid]}}).

ready(Uid, Type) ->
  #{ready := Ready, player := Players} = Room = load(),
  if
    Type == 1 -> down(Room#{ready => lists:usort([Uid | Ready])});
    true -> down(Room#{ready => lists:delete(Uid, Ready)})
  end,
  multi_cast(Players, {exec, {mod_room, player_ready, [Uid]}}).

down(RoomInfo) ->
  put(?PDict, RoomInfo).

load() ->
  get(?PDict).

multi_cast(Players, Msg) ->
  [gen_server:cast(Pid, Msg) || #{pid := Pid} <- Players].
