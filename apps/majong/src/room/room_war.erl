%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 28. 六月 2017 下午3:37
%%%-------------------------------------------------------------------
-module(room_war).
-author("cyy").
-define(PDict, room_war).
-include("majong_pb.hrl").
%% API
-export([
  choose_banker/4,
  zhuang/2,
  score/2,
  show/1
]).

choose_banker(Players, BankerType, Round, TotalRound) ->
  Uids = [Uid || #{uid := Uid} <- Players],
  Info = init(),
  Cards = get_cards(Uids),
  down(Info#{players => Uids, cards => Cards}),
%%  notify_cards(Cards),
  Banker = case BankerType of   %% 2: 轮庄 3: 随机庄  4: 固定庄
    1 -> undefined;
    2 ->
      Info1 = load(),
%%      #{l_zhuang := Lzhuang} = Info1 = load(),
%%      {NewList, Lzhuang1} = case Uids -- Lzhuang of
%%                              [] -> {Uids, []};
%%                              L -> {L, Lzhuang}
%%                            end,
      N = (TotalRound - Round + 1) rem length(Uids) + 1,
      Zhuang = lists:nth(N, Uids),
      down(Info1#{zhuang => {Zhuang, 1}}),
      Zhuang;
    3 ->
      N = rand:uniform(length(Uids)),
      Zhuang = lists:nth(N, Uids),
      Info1 = load(),
      down(Info1#{zhuang => {Zhuang, 1}}),
      Zhuang;
    4 ->
      [Zhuang] = lists:filtermap(fun(#{uid := Uid} = P) ->
        case maps:get(owner, P, 0) of
          1 -> {true, Uid};
          0 -> false
        end end, Players),
      Info1 = load(),
      down(Info1#{zhuang => {Zhuang, 1}}),
      Zhuang
  end,
  {Banker, Cards}.

notify_cards(Cards) ->
  {Pbs, Uids} = maps:fold(fun(K, V, {In, T}) ->
    {In ++ [#{uid => K, pai => V}], T ++ [K]} end, {[], []}, Cards),
  lager:info("notify cards : ~p", [Pbs]),
  multi_cast(Uids, {mod_room, notify_cards, [Pbs]}).

get_cards(Uids) ->
  L = dhlist:shuffle(lists:seq(0, 51)),
  Len = length(Uids),
  Map = lists:foldl(fun(N, M) ->
    Uid = lists:nth(N, Uids),
    Cards = lists:sublist(L, N * 5 - 4, 5),
    lager:info("get cards : ~p ~p", [N, Cards]),
    Cards1 = [trans(X) || X <- Cards],
    M#{Uid => Cards1} end, #{}, lists:seq(1, Len)),
  Map.

zhuang(Uid, Base) ->
  #{c_zhuang := Zhuang, players := Players} = Room = load(),
  Zhuang1 = Zhuang#{Base => maps:get(Base, Zhuang) ++ [Uid]},
  Room1 = Room#{c_zhuang => Zhuang1},
  #{1 := B, 2 := C, 3 := D} = Zhuang1,
  L = lists:usort(B ++ C ++ D),
  lager:info("l : ~p lengt : ~p", [L, length(Players)]),
  multi_cast(Players, {mod_room, notify_zhuang, [Uid, Base]}),
  if
    length(L) == length(Players) ->
      {ZhuangUid, Base1} = if
                             D =/= [] ->
                               N = rand:uniform(length(D)),
                               ZhuangId = lists:nth(N, D),
                               {ZhuangId, 3};
                             C =/= [] ->
                               N = rand:uniform(length(C)),
                               ZhuangId = lists:nth(N, C),
                               {ZhuangId, 2};
                             true ->
                               N = rand:uniform(length(B)),
                               ZhuangId = lists:nth(N, B),
                               {ZhuangId, 1}
                           end,
      lager:info("notify zhuang : ~p ~p", [ZhuangUid, Base1]),
      down(Room1#{zhuang => {ZhuangUid, Base1}}),
      multi_cast(Players, {mod_room, notify_zhuang_end, [ZhuangUid, Base1]});
    true ->
      down(Room1)
  end.

score(Uid, Score) ->
  Info = load(),
  #{zhuang := {Zhuang, Base}, cards := C, total := Total, players := Uids, score := Scores} = Info,
  Cards1 = maps:get(Uid, C),
  Cards2 = maps:get(Zhuang, C),
  Add = case pokers_type:cmp(Cards1, Cards2) of
          1 -> pokers_type:get_score(Cards1) * Score * Base;
          0 -> pokers_type:get_score(Cards2) * Score * Base * -1
        end,
  ZhuangScore = maps:get(Zhuang, Total, 0),
  UidScore = maps:get(Uid, Total, 0),
  down(Info#{total => #{Uid => UidScore + Add, Zhuang => ZhuangScore - Add}, score => Scores#{Uid => Add}}),
  multi_cast(Uids, {mod_room, notify_score, [Uid, Score, Add]}),
  N = length(Uids) - maps:size(Scores),
  if
    N == 2 -> notify_cards(C);
    true -> ok
  end.

show(Uid) ->
  #{players := Uids, show_player := ShowPlayer} = RoomInfo = load(),
  S1 = lists:usort([Uid | ShowPlayer]),
  down(RoomInfo#{show_player => S1}),
  if
    length(S1) == length(Uids) -> multi_cast(Uids, {mod_room, notify_all_show, []});
    true -> ok
  end,
  multi_cast(Uids, {mod_room, notify_show, [Uid]}).

trans(Num) ->
  Type = trunc(Num / 13) + 1,
  N = Num rem 13 + 1,
  #{type => Type, id => N}.

down(Info) ->
  put(?PDict, Info).

init() ->
  Info = load(),
  Info#{c_zhuang => #{1 => [], 2 => [], 3 => []}, cards => #{}, score => #{}, players => [], show_player => []}.

load() ->
  case get(?PDict) of
    undefined ->
      #{l_zhuang => [], zhuang => {0, 1}, c_zhuang => #{1 => [], 2 => [], 3 => []}, cards => #{}, score => #{}, players => [], total => #{}};
    Info -> Info
  end.

multi_cast(Uids, Msg) ->
  [player:async_exec(Uid, Msg) || Uid <- Uids].
