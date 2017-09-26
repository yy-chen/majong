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
%%-define(AppId, "wx4403974ea8b2b025").
%%-define(AndroidSecret, "589365546327463d7a68c0bcbcf826e6").
%% API
-export([
  login/2
]).

login(Channel, Code) ->
  lager:info("channel : ~p code : ~p", [Channel, Code]),
  Secret = if
             Channel == 1 -> app_ctl:get_cfg(android_secrect)
           end,
  Url = "https://api.weixin.qq.com/sns/oauth2/access_token" ++
  "?appid=" ++ app_ctl:get_cfg(appid) ++ "&secret=" ++ Secret ++ "&code=" ++ Code ++ "&grant_type=authorization_code",
  {ok, {{_, 200, _}, _, Res}} = httpc:request(get, {Url, []}, [], []),
  Res1 = jiffy:decode(Res, [return_maps]),
  case maps:get(<<"openid">>, Res1, undefined) of
    undefined -> {-1, #{}};
    OpenId ->
      #{<<"access_token">> := AccessToken} = Res1,
      Url1 = "https://api.weixin.qq.com/sns/userinfo?access_token=" ++ binary_to_list(AccessToken)
        ++ "&openid=" ++ binary_to_list(OpenId),
      {ok, {{_, 200, _}, _, UserInfo}} = httpc:request(get, {Url1, []}, [], []),
      UserInfo1 = jiffy:decode(UserInfo, [return_maps]),
      MgoUser = mgo_user:load(OpenId),
      R = merge(UserInfo1, MgoUser),
      {0, R}
  end.

merge(UserInfo1, UserInfo2) ->
  #{<<"headimgurl">> := Logo, <<"nickname">> := Name} = UserInfo1,
  lager:info("userinfo1 : ~p  usesrinfo2 : ~p", [UserInfo1, UserInfo2]),
  UserInfo2#{logo => Logo, name => Name}.
