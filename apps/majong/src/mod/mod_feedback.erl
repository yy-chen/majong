%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 15. 八月 2017 下午11:21
%%%-------------------------------------------------------------------
-module(mod_feedback).
-author("cyy").
-include("majong_pb.hrl").

%% API
-export([
  dispatch/2
]).

dispatch(C, Bin) ->
  case C of
    1 -> feedback(Bin)
  end.

feedback(Bin) ->
  #req_content{weixin = Wx, text = Text} = majong_pb:decode_msg(Bin, req_content),
  lager:info("wx : ~p  text : ~p", [Wx, Text]),
  player:rsp(4, 1, #rsp_content{status = 0}).
