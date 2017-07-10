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

]).

load(undefined) ->  %%新建
  ok;
load(Uid) ->
  ok.
