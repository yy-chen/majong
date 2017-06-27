%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 25. 六月 2017 下午3:57
%%%-------------------------------------------------------------------
-module(mgo_comm).
-author("cyy").
-define(Topology, majong_pool_topology).
%% API
-export([
  init_pool/0,
  get_conn/0
]).

init_pool() ->
  {Mongo, Db} = app_ctl:get_cfg(mongo),
  Options = [
    {name, majong_pool},
    {pool_size, 10},
    {max_overflow, 50},
    {register, ?Topology}
  ],
  WorkOpts = [{database, Db}],
  {ok, _Pid} = mongo_api:connect(single, Mongo, Options, WorkOpts).

get_conn() ->
  ?Topology.
