%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 29. 五月 2017 下午4:03
%%%-------------------------------------------------------------------
-module(room_sup).
-author("cyy").

-behaviour(supervisor).
-define(SERVER, ?MODULE).
%% API
-export([
  start_link/0,
  init/1
]).

start_link() ->
  supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
  RestartStrategy = one_for_one,
  MaxRestarts = 1000,
  MaxSecondsBetweenRestarts = 3600,
  SupFlags = {RestartStrategy, MaxRestarts, MaxSecondsBetweenRestarts},
  {ok, {SupFlags, []}}.
