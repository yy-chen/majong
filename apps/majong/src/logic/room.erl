%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 五月 2017 下午4:11
%%%-------------------------------------------------------------------
-module(room).
-author("cyy").

%% API
-export([]).

lanuch(RoomId) ->
  ChildSpec = {RoomId, {?MODULE, start_link, [RoomId]}, transient, 5000, worker, [room]},
  supervisor:start_child(room_sup, ChildSpec).

create() ->
  RoomId =
  ok.
