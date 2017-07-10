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
-define(PDict, mod_play).

%% API
-export([
  dispatch/2
]).

-export([
  id/0,
  id/1,
  base/0
]).

dispatch(C, B) ->
  case C of
    1 -> login(B);
    2 -> pub(B)
  end.

login(Bin) ->
  #req_login{code = Code, channel = Channel, user_id = UserId} = majong_pb:decode_msg(Bin, req_login),
  {Status, UserInfo} = if
    Channel == 1 orelse Channel == 2 -> wx_login:login(Code, Channel);
    true -> ok
  end,
  lager:info("code : ~p", [Code]),
  player:rsp(1, 1, #rsp_login{status = Status, coins = 111, gems = 121}).

pub(_Bin) ->
  player:rsp(1, 2, #rsp_pub{status = 0, pub = <<"666666">>}),
  ok.

id(Uid) -> put(user_id, Uid).
id() -> get(user_id).
base() -> maps:with([uid, name, logo], get(?PDict)).
