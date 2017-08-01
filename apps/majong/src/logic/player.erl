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

start_link() ->
  gen_server:start_link(?MODULE, [], []).

pid(Pid) when is_pid(Pid) -> Pid;
pid(Uid) -> gproc:whereis_name({n, l, {uid, Uid}}).

sync_exec(Info, {M, F, A}) ->
  case pid(Info) of
    undefined -> {error, no_player};
    Pid -> gen_server:call(Pid, {exec, M, F, A})
  end.

async_exec(Info, {M, F, A}) ->
  case pid(Info) of
    undefined -> {error, no_player};
    Pid -> gen_server:cast(Pid, {exec, M, F, A})
  end.

init([]) ->
  process_flag(trap_exit, true),
  lager:info("player init"),
  {ok, #state{net = undefined}}.

handle_call({exec, M, F, A}, _, State) ->
  Ans = try
          erlang:apply(M, F, A)
        catch
          T: R ->
            lager:info("exec error type : ~p excetion : ~p mod : ~p f : ~P a : ~p ", [T, R, M, F, A]),
            {error, exception}
        end,
  {reply, Ans, State};

handle_call(_, _, State) ->
  {reply, ok, State}.

handle_cast({exec, M, F, A}, State) ->
  try
    erlang:apply(M, F, A)
  catch
    T: E ->
      lager:info("aexec type : ~p excetion : ~p m : ~p f : ~p a : ~p", [T, E, M, F, A])
  end,
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
  ok.

dispatch(<<G:32, C:32, Bin/binary>>) ->
  lager:info("g : ~p c : ~p", [G, C]),
  case G of
    1 -> mod_play:dispatch(C, Bin);
    2 -> mod_room:dispatch(C, Bin)
  end.

rsp(G, C, R) ->
  Bin = iolist_to_binary(majong_pb:encode_msg(R)),
  dhtcp_conn:send(get(?Conn), <<G:32, C:32, Bin/binary>>),
  ok.
