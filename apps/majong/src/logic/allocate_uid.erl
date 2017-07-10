%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 09. 七月 2017 下午3:15
%%%-------------------------------------------------------------------
-module(allocate_uid).
-author("cyy").

%% API
-export([
  allocate/0,
  start_pool/0,
  start_link/2,
  init/1,
  handle_call/3,
  handle_cast/2,
  handle_info/2,
  code_change/3,
  terminate/2
]).

-define(SERVER, ?MODULE).

-define(MAX, 999999).
-record(state, {
  index :: integer(),
  uid_dict = dict:new()
}).


allocate() ->
  Index = rand:uniform(90) + 9,
  gen_server:call(list_to_atom("allocate_uid" ++ integer_to_list(Index)), get).

start_pool() ->
  Restart = permanent,
  Shutdown = 2000,
  Type = worker,
  AllocateUid = "allocate_uid",
  Fun = fun(Index) ->
    ChildName = list_to_atom(AllocateUid ++ integer_to_list(Index)),
    Spec = {ChildName, {allocate_uid, start_link, [ChildName, Index]}, Restart, Shutdown, Type, [allocate_uid]},
    supervisor:start_child(majong_sup, Spec)
    end,
  lists:map(Fun, lists:seq(10, 99)).

start_link(Name, Index) ->
  gen_server:start_link({local, Name}, ?MODULE, [Index], []).

init([Index]) ->
  Uids = mgo_user:get_uids(Index),
  UidDict = dict:new(),
  lists:foreach(fun(Uid) -> dict:store(Uid, 1, UidDict) end, Uids),
  {ok, #state{index = Index, uid_dict = UidDict}}.

handle_call(get, _From, #state{index = Index, uid_dict = NumDict} = State) ->
  {Uid, Dic} = get_uid(Index, NumDict),
  {reply, {ok, Uid}, State#state{uid_dict = Dic}};

handle_call(_Req, _From, State) ->
  {reply, ok, State}.

handle_cast(_Req, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

terminate(_Reason, _State) ->
  ok.

code_change(_Old, State, _Extra) ->
  {ok, State}.

-spec get_uid(Index :: integer(), _) -> {Uid :: integer(), _}.
get_uid(Index, NumDic) ->
  NewUid = Index * (?MAX + 1) + rand:uniform(?MAX),
  case dict:find(NewUid, NumDic) of
    {ok, _Value} ->
      get_uid(Index, NumDic);
    error ->
      dict:store(NewUid, 1, NumDic),
      {NewUid, NumDic}
  end.