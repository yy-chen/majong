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
-record(state, {}).
-behaviour(gen_server).
%% API
-export([
  init/1,
  start_link/1,
  handle_info/2,
  handle_cast/2,
  handle_call/3,
  code_change/3,
  terminate/2
]).

-export([
  create/2,
  pid/1,
  sync_exec/2,
  async_exec/2
]).

lanuch(RoomId) ->
  ChildSpec = {RoomId, {?MODULE, start_link, [RoomId]}, transient, 5000, worker, [room]},
  supervisor:start_child(room_sup, ChildSpec).

create(PlayerInfo, RoomInfo) ->
  RoomId = mod_svr:room_id(),
  ChildSpec = {RoomId, {?MODULE, start_link, [#{player => PlayerInfo#{<<"pid">> => self()}, room_id => RoomId, room_info => RoomInfo}]}, transient, 5000, worker, [room]},
  case supervisor:start_child(room_sup, ChildSpec) of
    {ok, _} -> {ok, RoomId};
    {error, Error} ->
      lager:info("create room id : ~p  error : ~p", [RoomId, Error]),
      {error, Error}
  end.

start_link(Info) -> gen_server:start_link(?MODULE, [Info], []).

pid(Pid) when is_pid(Pid) -> Pid;
pid(RoomId) -> gproc:whereis_name({n, l, {room_id, RoomId}}).

sync_exec(Info, {M, F, A}) ->
  case pid(Info) of
    undefined -> {error, no_room};
    Pid -> gen_server:call(Pid, {exec, M, F, A})
  end.

async_exec(Info, {M, F, A}) ->
  case pid(Info) of
    undefined -> {error, no_room};
    Pid -> gen_server:cast(Pid, {exec, M, F, A})
  end.

init([Info]) ->
  #{room_id := RoomId} = Info,
  case gproc:register_name({n, l, {room_id, RoomId}}, self()) of
    no ->
      lager:info("room id : ~p already", [RoomId]),
      {stop, already_reg};
    yes ->
      lager:info("room id : ~p create success", [RoomId]),
      room_base:create(Info),
      {ok, #state{}}
  end.

handle_call({exec, M, F, A}, _, State) ->
  Ans = erlang:apply(M, F, A),
  {reply, Ans, State};
handle_call(_Request, _From, State) -> {reply, ok, State}.

handle_cast({exec, M, F, A}, State) ->
  erlang:apply(M, F, A),
  {noreply, State};
handle_cast(_Request, State) -> {noreply, State}.

handle_info(_Info, State) -> {noreply, State}.

terminate(_Reason, _State) -> ok.

code_change(_Old, State, _Extra) -> {ok, State}.