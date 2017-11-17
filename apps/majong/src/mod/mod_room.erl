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
  room_id/0
]).

-export([
  dispatch/2,
  create/1,
  new_player/1,
  player_leave/1,
  player_ready/2,
  game_start/2,
  game_start/3,
  player_chat/1,
  notify_zhuang/2,
  notify_zhuang_end/2,
  notify_cards/1,
  notify_score/3,
  notify_show/1,
  notify_all_show/0,
  notify_dismiss/0
]).

%%#{room_id => int()}

dispatch(C, Bin) ->
  case C of
    1 -> create(Bin);
    2 -> join(Bin);
    4 -> leave();
    6 -> ready(Bin);
    8 -> start();
    10 -> zhuang(Bin);
    13 -> score(Bin);
    16 -> chat(Bin);
    18 -> show();
    21 -> dismiss()
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

game_start(Round, Cards) ->
  Uid = mod_play:id(),
  Cards1 = maps:get(Uid, Cards),
  lager:info("game start round : ~p", [Round, Cards1]),
  player:rsp(2, 9, #rsp_game_start{round = Round, cards = unit2pb(Cards1)}).     %%抢庄模式 没庄家
game_start(Uid, Round, Cards) ->
  Uid1 = mod_play:id(),
  Cards1 = maps:get(Uid1, Cards),
  lager:info("game start round : ~p", [Round]),
  player:rsp(2, 9, #rsp_game_start{uid = Uid, round = Round, cards = unit2pb(Cards1)}).

zhuang(Bin) ->
  #req_zhuang{base = Base} = majong_pb:decode_msg(Bin, req_zhuang),
  #{room_id := RoomId} = load(),
  case room:sync_exec(RoomId, {room_war, zhuang, [mod_play:id(), Base]}) of
    {error, _} -> player:rsp(2, 10, #rsp_zhuang{status = -1});
    _ -> player:rsp(2, 10, #rsp_zhuang{status = 0})
  end.

notify_zhuang(Uid, Base) ->
  player:rsp(2, 11, #rsp_player_zhuang{uid = Uid, base = Base}).

notify_zhuang_end(Uid, Base) ->
  player:rsp(2, 12, #rsp_zhuang_end{uid = Uid, base = Base}).

score(Bin) ->
  #req_score{score = Score} = majong_pb:decode_msg(Bin, req_score),
  #{room_id := RoomId} = load(),
  case room:sync_exec(RoomId, {room_war, score, [mod_play:id(), Score]}) of
    {error, _} -> player:rsp(2, 13, #rsp_score{status = -1});
    _ -> player:rsp(2, 13, #rsp_score{status = 0})
  end.

notify_score(Uid, Score, Delta) ->
  player:rsp(2, 14, #rsp_player_score{score = Score, uid = Uid, delta = Delta}).

notify_cards(Players) ->
  player:rsp(2, 15, #rsp_result{players = player2pb(Players)}).

show() ->
  #{room_id := RoomId} = load(),
  case room:sync_exec(RoomId, {room_war, show, [mod_play:id()]}) of
    {error, _} -> player:rsp(2, 18, #rsp_show{status = -1});
    _ -> player:rsp(2, 18, #rsp_show{status = 0})
  end.

notify_show(Uid) ->
  player:rsp(2, 19, #notify_show{uid = Uid}).

notify_all_show() ->
  player:rsp(2, 20, #notify_all_show{}).

dismiss() ->
  #{room_id := RoomId} = load(),
  case room:sync_exec(RoomId, {room_base, dismiss, [mod_play:id()]}) of
    {error, _} -> player:rsp(2, 21, #rsp_dismiss{status = -1});
    _ -> player:rsp(2, 21, #rsp_dismiss{status = 0})
  end.

notify_dismiss() ->
  player:rsp(2, 22, #notify_dismiss{}).

chat(Bin) ->
  #req_chat{msg = Msg, voice = Voice} = majong_pb:decode_msg(Bin, req_chat),
  Url = case Voice of
          [V] -> ali_file:upload(V);
          _ -> undefined
        end,
  #{room_id := RoomId} = load(),
  room:async_exec(RoomId, {room_base, chat, [mod_play:id(), Url, Msg]}),
  player:rsp(2, 16, #rsp_chat{status = 0}).

player_chat(#{uid := Uid, msg := Msg, url := Url}) ->
  Self = mod_play:id(),
  if
    Self == Uid -> ok;
    true -> player:rsp(2, 17, #rsp_player_chat{uid = Uid, url = Url, msg = Msg})
  end.

room_id() ->
  case load() of
    undefined -> undefined;
    #{room_id := RoomId} -> RoomId
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
  Index = maps:get(index, Player, 0),
  Owner = maps:get(owner, Player, undefined),
  Pai = unit2pb(maps:get(pai, Player, [])),
  Delta = maps:get(delta, Player, undefined),
  #pb_player{name = Name, logo = Logo, coins = Coins, index = Index, owner = Owner, uid = Uid, pai = Pai, delta = Delta}.

unit2pb(L) when is_list(L) ->
  [unit2pb(P) || P <- L];
unit2pb(#{id := Id, type := Type}) ->
  #pb_unit{num = Id, type = Type}.
