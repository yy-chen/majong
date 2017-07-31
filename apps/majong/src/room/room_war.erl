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
  choose_banker/2
]).

choose_banker(Players, BankerType) ->
  case BankerType of
    1 -> undefined;
    2 -> ok;
    3 -> ok;
    4 -> ok
  end.

get_cards(Uids) ->
  L = dhlist:shuffle(lists:seq(0, 51)),
  Len = length(Uids),
  Map = lists:foldl(fun(N, M) ->
    Uid = lists:nth(N, Uids),
    Cards = lists:split(L, N, N + 4),
    Cards1 = [trans(X) || X <- Cards],
    M#{Uid => Cards1} end, #{}, lists:seq(1, Len)),
  Info = load(),
  down(Info#{pai => Map}),
  Map.

trans(Num) ->
  Type = trunc(Num / 13) + 1,
  N = Num rem 13 + 1,
  #{type => Type, id => N}.

down(Info) ->
  put(?PDict, Info).

load() ->
  get(?PDict).
