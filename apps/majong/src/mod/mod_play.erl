%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 五月 2017 下午10:38
%%%-------------------------------------------------------------------
-module(mod_play).
-author("cyy").
-include("majong_pb.hrl").

%% API
-export([
  dispatch/2
]).

dispatch(C, B) ->
  case C of
    1 -> login(B);
    2 -> pub(B)
  end,
  ok.

login(Bin) ->
  #req_login{open_id = OpenId, token = Token} = majong_pb:decode_msg(Bin, req_login),
  lager:info("openid : ~p  token : ~p", [OpenId, Token]),
  player:rsp(1, 1, #rsp_login{status = 0, coins = 111, gems = 121}).

pub(_Bin) ->
  player:rsp(1, 2, #rsp_pub{status = 0, pub = <<"666666">>}),
  ok.
