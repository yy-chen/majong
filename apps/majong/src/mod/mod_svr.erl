%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 五月 2017 下午4:36
%%%-------------------------------------------------------------------
-module(mod_svr).
-author("cyy").
-define(Name, svr_cfg).
%% API
-export([
  init/0,
  room_id/0
]).

init() ->
  case ets:info(?Name) of
    undefined ->
      ets:new(?Name, [{keypos, 1}, named_table, public, set,
        {wirte_concurrency, true}, {read_concurrency, true}]);
    _ -> ok
  end.

insert(Tuple) -> ets:insert(?Name, Tuple).

lookup(Key) ->
  case ets:lookup(?Name, Key) of
    [] -> error;
    [A] -> A
  end.

room_id() ->
  Id = rand:uniform(100000),
  case lookup({room, Id}) of
    error ->
      insert({{room, Id}, true}),
      Id;
    _ ->
      room_id()
  end.
