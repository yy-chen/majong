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
%% API
-export([
  choose_banker/2,
  zhuang/2
]).

choose_banker(Players, BankerType) ->
  Uids = [Uid || #{uid := Uid} <- Players],
  Info = load(),
  Cards = get_cards(Uids),
  down(Info#{players => Uids, cards => Cards}),
  case BankerType of   %% 2: 轮庄 3: 随机庄  4: 固定庄
    1 -> undefined;
    2 ->
      Info1 = load(),
      #{l_zhuang := Lzhuang} = Info1 = load(),
      {NewList, Lzhuang1} = case Uids -- Lzhuang of
                              [] -> {Uids, []};
                              L -> {L, Lzhuang}
                            end,
      N = rand:uniform(length(NewList)),
      Zhuang = lists:nth(N, NewList),
      down(Info1#{zhuang => {Zhuang, 1}, l_zhuang => Lzhuang1 ++ [Zhuang]}),
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
  end.

get_cards(Uids) ->
  L = dhlist:shuffle(lists:seq(0, 51)),
  Len = length(Uids),
  Map = lists:foldl(fun(N, M) ->
    Uid = lists:nth(N, Uids),
    Cards = lists:split(L, N, N + 4),
    Cards1 = [trans(X) || X <- Cards],
    M#{Uid => Cards1} end, #{}, lists:seq(1, Len)),
  Map.

zhuang(Uid, Base) ->
  #{c_zhuang := Zhuang, players := Players} = Room = load(),
  Room1 = Room#{c_zhuang => #{Base => maps:get(Base, Zhuang) ++ [Uid]}},
  #{1 := B, 2 := C, 3 := D} = Zhuang,
  L = lists:usort(B ++ C ++ D),
  if
    L == length(Players) ->
      {Uid, Base} = if
                      D =/= [] ->
                        N = rand:uniform(length(D)),
                        Zhuang = lists:nth(N, D),
                        {Zhuang, 3};
                      C =/= [] ->
                        N = rand:uniform(length(C)),
                        Zhuang = lists:nth(N, C),
                        {Zhuang, 2};
                      true ->
                        N = rand:uniform(length(B)),
                        Zhuang = lists:nth(N, B),
                        {Zhuang, 1}
                    end,
      down(Room1#{zhuang => {Uid, Base}}),
      multi_cast(Players, {mod_room, notify_zhuang, [Uid, Base]});
    true ->
      down(Room1)
  end.

trans(Num) ->
  Type = trunc(Num / 13) + 1,
  N = Num rem 13 + 1,
  #{type => Type, id => N}.

down(Info) ->
  put(?PDict, Info).

load() ->
  case get(?PDict) of
    undefined ->
      #{l_zhuang => [], zhuang => {0, 1}, c_zhuang => #{1 => [], 2 => [], 3 => []}, cards => #{}, score => #{}, players => []};
    Info -> Info
  end.

multi_cast(Uids, Msg) ->
  [player:async_exec(Uid, Msg) || Uid <- Uids].
