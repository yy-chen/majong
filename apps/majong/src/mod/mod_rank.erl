%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 26. 九月 2017 下午11:22
%%%-------------------------------------------------------------------
-module(mod_rank).
-author("cyy").

%% API
-export([
  dispatch/2
]).
-include("majong_pb.hrl").

dispatch(C, _Bin) ->
  case C of
    1 -> coin_rank();
    2 -> gem_rank()
  end.

coin_rank() ->
  Player1 = #pb_rank_player{name = <<"player1">>, logo = <<"">>, num = 1000000},
  Player2 = #pb_rank_player{name = <<"player2">>, logo = <<"">>, num = 100},
  player:rsp(6, 1, #rsp_coins_rank{players = [Player1, Player2]}).

gem_rank() ->
  Player1 = #pb_rank_player{name = <<"player1">>, logo = <<"">>, num = 99},
  Player2 = #pb_rank_player{name = <<"player2">>, logo = <<"">>, num = 33},
  player:rsp(6, 2, #rsp_gem_rank{players = [Player1, Player2]}).
