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
    {register, ?Topology},

    {overflow_ttl, 1000}, % number of milliseconds for overflow workers to stay in pool before terminating
    {overflow_check_period, 1000}, % overflow_ttl check period for workers (in milliseconds)

    {localThresholdMS, 1000},

    {connectTimeoutMS, 20000},
    {socketTimeoutMS, 100},

    {serverSelectionTimeoutMS, 30000},
    {waitQueueTimeoutMS, 1000},

    {heartbeatFrequencyMS, 10000},
    {minHeartbeatFrequencyMS, 1000},

    {rp_mode, primary},

    {rp_tags, [{tag, 1}]}
  ],
  WorkOpts = [{database, Db}],
  {ok, _Pid} = mongo_api:connect(single, Mongo, Options, WorkOpts).

get_conn() ->
  ?Topology.
