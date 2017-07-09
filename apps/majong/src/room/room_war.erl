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
  end,
  ok.
