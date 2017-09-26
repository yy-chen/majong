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
  Time = dhtime:timestamp(),
  Uid = mod_play:id(),
  T1 = integer_to_binary(Uid),
  T2 = integer_to_binary(Time),
  OrderId = << T1/binary, <<"_">>/binary,  T2/binary>>,
  player:rsp(5, 1, #rsp_pay{status = 0, coins = Rmb * 10}).
