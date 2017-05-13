%%%-------------------------------------------------------------------
%% @doc majong top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(majong_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Ctl = app_ctl:child_spec("config/majong.config", mod_ctl),
    {ok, { {one_for_all, 5, 10}, [Ctl]} }.

%%====================================================================
%% Internal functions
%%====================================================================
