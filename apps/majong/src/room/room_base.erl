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
-define(Ready, 1).
-define(Banker, 2).
-define(Score, 3).
%% API
-export([
  create/1,
  join/1,
  leave/1,
  ready/2,
  start/1,
  chat/3,
  dismiss/1
]).

%%% players => [#{uid => 1, logo => 2, name => 3}]
%%% owner => int()
%%% room_info => #{round => int(), pay => int(), banker => int(), special => int(), type => int()}
%%% ready => []
create(#{player := PlayerInfo, room_id := RoomId, room_info := RoomInfo}) ->
  #{uid := Uid} = PlayerInfo,
  down(#{round => 0, players => [PlayerInfo#{index => 1, owner => 1}], owner => Uid, room_info => RoomInfo#{room_id => RoomId, owner => Uid}, num => 1, ready => [], state => ?Ready}).

join(Player) ->
  #{players := Players, num := Num} = Room = load(),
  if
    Num == 5 -> {error, full};     %%满人
    true ->
      down(Room#{players => Players ++ [Player], num => Num + 1}),
      multi_cast(Players, {mod_room, new_player, [Player]}),
      Room
  end.

leave(Uid) ->
  #{players := Players, num := Num} = Room = load(),
  {NewPlayers, F} = lists:foldl(fun(Player, {NPlayers, Flag}) ->
    #{uid := PlayerUid} = Player,
    if
      Uid == PlayerUid -> {NPlayers, 1};
      true -> {NPlayers ++ [Player], Flag}
    end end, {[], 0}, Players),
  down(Room#{players => NewPlayers, num => Num - F}),
  multi_cast(NewPlayers, {mod_room, player_leave, [Uid]}).

ready(Uid, Type) ->
  #{ready := Ready, players := Players} = Room = load(),
  if
    Type == 1 -> down(Room#{ready => lists:usort([Uid | Ready])});
    true -> down(Room#{ready => lists:delete(Uid, Ready)})
  end,
  multi_cast(Players, {mod_room, player_ready, [Uid, Type]}).

start(Uid) ->
  #{owner := Owner, ready := Ready, players := Players, room_info := RoomInfo, state := State} = Room = load(),
  if
    Owner =/= Uid -> {error, no_owner};
    length(Ready) =/= length(Players) - 1 -> {error, no_ready};  %%房主不用准备
    length(Ready) == 0 -> {error, no_play};
    State =/= ?Ready -> {error, no_ready};
    true ->
      #{banker := BankerType, round := Round} = RoomInfo,
      down(Room#{ready => [], round => Round + 1}),
      case room_war:choose_banker(Players, BankerType) of
        undefined -> multi_cast(Players, {mod_room, game_start, [Round]});
        Uid1 -> multi_cast(Players, {mod_room, game_start, [Uid1, Round]})
      end
  end.

dismiss(Uid) ->
  #{owner := Owner, players := Players} = _Room = load(),
  if
    Owner =/= Uid -> {error, no_owner};
    true -> multi_cast(Players, {mod_room, dismiss, []})
  end.

chat(Uid, Url, Msg) ->
  #{players := Players} = load(),
  multi_cast(Players, {mod_room, player_chat, [#{uid => Uid, msg => Msg, url => Url}]}).

down(RoomInfo) ->
  put(?PDict, RoomInfo).

load() ->
  get(?PDict).

multi_cast(Players, Msg) ->
  [player:async_exec(Pid, Msg) || #{pid := Pid} <- Players].
