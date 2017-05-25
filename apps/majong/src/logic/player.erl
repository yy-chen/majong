%% gen_server callbacks
-module(player).
-author("songxiao").

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
  rsp/3
]).

start_link() ->
  gen_server:start_link(?MODULE, [], []).

init([]) ->
  process_flag(trap_exit, true),
  lager:info("player init"),
  {ok, #state{net = undefined}}.

handle_call(_, _, State) ->
  {reply, ok, State}.

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
  ok.

dispatch(<<G:32, C:32, Bin/binary>>) ->
  lager:info("g : ~p c : ~p", [G, C]),
  case G of
    1 -> mod_play:dispatch(C, Bin)
  end,
  ok.

rsp(G, C, R) ->
  Bin = iolist_to_binary(majong_pb:encode_msg(R)),
  dhtcp_conn:send(get(?Conn), <<G:32, C:32, Bin/binary>>),
  ok.
