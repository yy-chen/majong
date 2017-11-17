%% gen_server callbacks
-module(player).

-behaviour(gen_server).
-record(state, {net :: pid()}).
-define(Conn, dhtcp_conn).

-export([init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  start_link/0,
  terminate/2,
  code_change/3]).

-export([
  rsp/3,
  sync_exec/2,
  async_exec/2
]).

-include("majong_pb.hrl").

start_link() ->
  gen_server:start_link(?MODULE, [], []).

pid(Pid) when is_pid(Pid) -> Pid;
pid(Uid) -> gproc:whereis_name({n, l, {uid, Uid}}).

sync_exec(Info, {M, F, A}) ->
  lager:info("sync : ~p", [pid(Info)]),
  case pid(Info) of
    undefined -> {error, no_player};
    Pid -> gen_server:call(Pid, {exec, M, F, A})
  end.

async_exec(Info, {M, F, A}) ->
  lager:info("async : ~p", [pid(Info)]),
  case pid(Info) of
    undefined -> {error, no_player};
    Pid -> gen_server:cast(Pid, {exec, M, F, A})
  end.

init([]) ->
  process_flag(trap_exit, true),
  lager:info("player init"),
  {ok, #state{net = undefined}}.

handle_call({exec, M, F, A}, _, State) ->
  Ans = erlang:apply(M, F, A),
  {reply, Ans, State};

handle_call(_, _, State) ->
  {reply, ok, State}.

handle_cast({exec, M, F, A}, State) ->
  erlang:apply(M, F, A),
  {noreply, State};

handle_cast(_Request, State) ->
  {noreply, State}.

handle_info({dhtcp, _, Data}, S) -> %%接收到tcp数据
  lager:info("data : ~p", [Data]),
  dispatch(Data),
  {noreply, S};

handle_info({dhconn_start, Pid}, S) ->
  put(?Conn, Pid),
  {noreply, S};

handle_info(_Info, State) ->
  {noreply, State}.
code_change(_OldVsn, State, _Extra) ->
  {ok, State}.
terminate(_Reason, _State) ->
  gproc:goodbye(),
  lager:info("player terminate"),
  case mod_room:room_id() of
    undefined -> ok;
    RoomId ->
      Uid = mod_play:id(),
      room:async_exec(RoomId, {room_base, leave, [Uid]})
  end,
  mod_play:save(),
  ok.

dispatch(<<G:32, C:32, Bin/binary>>) ->
  lager:info("g : ~p c : ~p", [G, C]),
  case G of
    0 -> rsp(0, 0, #rsp_heart{time = dhtime:local_timestamp()});
    1 -> mod_play:dispatch(C, Bin);
    2 -> mod_room:dispatch(C, Bin);
    4 -> mod_feedback:dispatch(C, Bin);
    5 -> mod_pay:dispatch(C, Bin);
    6 -> mod_rank:dispatch(C, Bin);
    100 -> mod_play:client_data(C, Bin)
  end.

rsp(G, C, R) ->
  Bin = iolist_to_binary(majong_pb:encode_msg(R)),
  dhtcp_conn:send(get(?Conn), <<G:32, C:32, Bin/binary>>),
  ok.
