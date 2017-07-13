%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 七月 2017 下午6:57
%%%-------------------------------------------------------------------
-module(mgo_user).
-author("cyy").
-define(Coll, player).
%% API
-export([
  load/1
]).

load(undefined) ->  %%新建
  #{coins => 0, gems => 0, logo => <<"">>, name => <<"">>, uid => 12345678};
load(Uid) when is_integer(Uid)->
  #{coins => 0, gems => 0, logo => <<"">>, name => <<"">>, uid => 12345678};
load(OpenId) ->
  #{coins => 0, gems => 0, logo => <<"">>, name => <<"">>, uid => 12345678}.
