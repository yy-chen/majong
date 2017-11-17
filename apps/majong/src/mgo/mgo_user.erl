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
-define(SIZE, 1000000).
%% API
-export([
  load/1,
  get_uids/1,
  save/1,
  save_client_data/2,
  get_client_data/1
]).



load(undefined) ->  %%新建
  #{coins => 0, gems => 0, logo => <<"">>, name => <<"">>, uid => allocate_uid:allocate()};
load(Uid) when is_integer(Uid) ->
  Conn = mgo_comm:get_conn(),
  Doc = mongo_api:find_one(Conn, <<"users">>, #{<<"_id">> => Uid}, #{}),
  case Doc of
    #{<<"_id">> := Uid} ->
      dhmap:from_mongo(Doc);
    _ -> init()
  end;
load(_OpenId) ->
  #{coins => 0, gems => 0, logo => <<"">>, name => <<"">>, uid => allocate_uid:allocate()}.

save(#{uid := Uid} = Doc) ->
  Conn = mgo_comm:get_conn(),
  mongo_api:update(Conn, <<"users">>, #{<<"_id">> => Uid}, #{<<"$set">> => Doc}, #{upsert => true}).

init() ->
  #{coins => 0, gems => 0, uid => allocate_uid:allocate()}.

get_uids(Index) ->
  Conn = mgo_comm:get_conn(),
  Q = #{<<"_id">> => #{<<"$lt">> => (Index + 1) * ?SIZE, <<"$gte">> => Index * ?SIZE}},
  {ok, Cursor} = mongo_api:find(Conn, <<"users">>, Q, #{<<"_id">> => 1}),
  Docs = mc_cursor:rest(Cursor),
  mc_cursor:close(Cursor),
  [X || #{<<"_id">> := X} <- Docs].

save_client_data(Uid, Data) ->
  Conn = mgo_comm:get_conn(),
  mongo_api:update(Conn, <<"client_data">>, #{<<"_id">> => Uid}, #{<<"$set">> => #{<<"_id">> => Uid, <<"data">> => Data}}, #{upsert => true}),
  ok.

get_client_data(Uid) ->
  Conn = mgo_comm:get_conn(),
  Doc = mongo_api:find_one(Conn, <<"client_data">>, #{<<"_id">> => Uid}, #{}),
  case Doc of
    #{<<"data">> := Data} -> Data;
    _ -> <<"">>
  end.
