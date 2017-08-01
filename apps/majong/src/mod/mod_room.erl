%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 五月 2017 下午5:01
%%%-------------------------------------------------------------------
-module(mod_room).
-author("cyy").
-include("majong_pb.hrl").
-define(PDict, mod_room).
%% API
-export([
  dispatch/2,
  create/1,
  new_player/1,
  player_leave/1,
  player_ready/2,
  game_start/0,
  game_start/1,
  player_chat/1
]).

%%#{room_id => int()}

dispatch(C, Bin) ->
  case C of
    1 -> create(Bin);
    2 -> join(Bin);
    4 -> leave();
    6 -> ready(Bin);
    8 -> start();
    16 -> chat(Bin)
  end.

create(Bin) ->
  #req_create_room{round = Round, pay = Pay, banker = Banker, special = Special, type = Type} = majong_pb:decode_msg(Bin, req_create_room),
  lager:info("round : ~p pay : ~p banker : ~p special : ~p type : ~p", [Round, Pay, Banker, Special, Type]),
  RoomInfo = #{round => Round, pay => Pay, banker => Banker, special => Special, type => Type},
  Uid = mod_play:id(),
  PlayerInfo = mod_play:base(),
  case room:create(PlayerInfo, RoomInfo) of
    {ok, RoomId} ->
      lager:info("uid : ~p create success : ~p", [Uid, RoomId]),
      down(#{room_id => RoomId}),
      player:rsp(2, 1, #rsp_create_room{status = 0, room_id = RoomId, coins = 100});
    {error, Reason} ->
      lager:info("error : ~p", [Reason]),
      player:rsp(2, 1, #rsp_create_room{status = -1})
  end.

join(Bin) ->
  #req_join{id = RoomId} = majong_pb:decode_msg(Bin, req_join),
  Info = mod_play:base(),
  lager:info("id : ~p", [RoomId]),
  case room:sync_exec(RoomId, {room_base, join, [Info#{pid => self()}]}) of
    {error, _} -> player:rsp(2, 2, #rsp_join{status = -1});
    #{room_info := RoomInfo, players := Players} ->
      PbRoom = room2pb(RoomInfo),
      lager:info("rsp join room info : ~p", [RoomInfo]),
      lager:info("rsp join players : ~p", [Players]),
      PbPlayers = player2pb(Players),
      down(#{room_id => RoomId}),
      player:rsp(2, 2, #rsp_join{status = 0, players = PbPlayers, room_info = PbRoom})
  end.

new_player(Player) ->
  lager:info("new player : ~p", [Player]),
  player:rsp(2, 3, #rsp_new_player{player = player2pb(Player)}).

leave() ->
  Uid = mod_play:id(),
  #{room_id := RoomId} = load(),
  room:async_exec(RoomId, {room_base, leave, [Uid]}),
  clear(),
  player:rsp(2, 4, #rsp_leave{status = 0}).

player_leave(Uid) ->
  player:rsp(2, 5, #rsp_player_leave{uid = Uid}).

ready(Bin) ->
  #req_ready{type = Type} = majong_pb:decode_msg(Bin, req_ready),
  Uid = mod_play:id(),
  #{room_id := RoomId} = load(),
  room:async_exec(RoomId, {room_base, ready, [Uid, Type]}),
  player:rsp(2, 6, #rsp_ready{status = 0}).

player_ready(Uid, Type) ->
  player:rsp(2, 7, #rsp_player_ready{uid = Uid, type = Type}).

start() ->
  #{room_id := RoomId} = load(),
  case room:sync_exec(RoomId, {room_base, start, [mod_play:id()]}) of
    {error, _} -> player:rsp(2, 8, #rsp_start{status = -1});
    _ -> player:rsp(2, 8, #rsp_start{status = 0})
  end.

game_start() -> player:rsp(2, 9, #rsp_game_start{}).     %%抢庄模式 没庄家
game_start(Uid) -> player:rsp(2, 9, #rsp_game_start{uid = Uid}).

chat(Bin) ->
  #req_chat{msg = Msg, voice = Voice} = majong_pb:decode_msg(Bin, req_chat),
  Url = ali_file:upload(binary_to_list(Voice)),
  #{room_id := RoomId} = load(),
  room:async_exec(RoomId, {room_base, chat, [mod_play:id(), Url, Msg]}),
  player:rsp(2, 16, #rsp_chat{status = 0}).

player_chat(#{uid := Uid, msg := Msg, url := Url}) ->
  Self = mod_play:id(),
  if
    Self == Uid -> ok;
    true -> player:rsp(2, 17, #rsp_player_chat{uid = Uid, url = Url, msg = Msg})
  end.

load() ->
  get(?PDict).
down(Room) ->
  put(?PDict, Room).
clear() ->
  erase(?PDict).

room2pb(Room) ->
  #{room_id := RoomId, owner := Owner, round := Round, pay := Pay, banker := Banker, special := Special, type := Type} = Room,
  #pb_room_info{room_id = RoomId, owner = Owner, round = Round, pay = Pay, banker = Banker, special = Special, type = Type}.

player2pb(Players) when is_list(Players) ->
  [player2pb(Player) || Player <- Players];
player2pb(#{uid := Uid} = Player) ->
  lager:info("player : ~p", [Player]),
  Name = maps:get(name, Player, undefined),
  Logo = maps:get(logo, Player, undefined),
  Coins = maps:get(coins, Player, undefined),
  Index = maps:get(index, Player, undefined),
  Owner = maps:get(owner, Player, undefined),
  #pb_player{name = Name, logo = Logo, coins = Coins, index = Index, owner = Owner, uid = Uid}.

