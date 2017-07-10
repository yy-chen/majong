%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 04. 七月 2017 下午2:47
%%%-------------------------------------------------------------------
-module(wx_login).
-author("cyy").
-define(AppId, "wx4403974ea8b2b025").
-define(AndroidSecret, "wx4403974ea8b2b025589365546327463d7a68c0bcbcf826e6").
%% API
-export([
  login/2
]).

login(Channel, Code) ->
  Secret = if
             Channel == 1 -> ?AndroidSecret
           end,
  Url = "https://api.weixin.qq.com/sns/oauth2/access_token" ++
  "?appid=" ++ ?AppId ++ "&secret=" ++ Secret ++ "&code="++Code++"&grant_type=authorization_code",
  {ok, {{_, 200, _}, _, Res}} = httpc:request(get, {Url, []}, [], []),
  lager:info("res : ~p", [jiffy:decode(Res, [return_maps])]),
  {0, #{}}.
