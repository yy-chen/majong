%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 八月 2017 下午11:24
%%%-------------------------------------------------------------------
-module(mod_pay).
-author("cyy").
-include("majong_pb.hrl").
%% API
-export([
  dispatch/2
]).

dispatch(C, Bin) ->
  case C of
    1 -> pay(Bin)
  end.

pay(Bin) ->
  #req_pay{rmb = Rmb} = majong_pb:decode_msg(Bin, req_pay),
  lager:info("rmb : ~p", [Rmb]),
  player:rsp(5, 1, #rsp_pay{status = 0, coins = Rmb * 10}).
