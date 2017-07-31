%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 24. 七月 2017 下午2:19
%%%-------------------------------------------------------------------
-module(pokers_type).
-author("cyy").

%% API
-export([
  niu/1,
  cmp/2
]).

perms() ->
  [
    [1,2,3],
    [1,2,4],
    [1,3,4],
    [2,3,4],
    [1,2,5],
    [1,3,5],
    [2,3,5],
    [1,4,5],
    [2,4,5],
    [3,4,5]
  ].

niu(Pokers) ->
  L = perms(),
  Pokers1 = [min(X, 10) || X <- Pokers],
  lists:max(lists:map(fun(Pre) ->
    PreCards = [lists:nth(N, Pokers1) || N <- Pre],
    case lists:sum(PreCards) rem 10 of
      0 ->
        Sum = lists:sum(Pokers1 -- PreCards) rem 10,
        if
          Sum == 0 -> 10;  %%牛牛
          true -> Sum
        end;
        _ -> 0
    end end, L)).

%% L1 > L2 -> 1   L1 < L2 -> 0
-spec cmp([#{id => integer(), type => integer()}], list()) -> ok.
cmp(L1, L2) ->
  [N1, N2, N3, N4, N5] = lists:reverse(lists:sort([(5 - Type) * 100 + Id || #{id := Id, type := Type} <- L1])),
  [M1, M2, M3, M4, M5] = lists:reverse(lists:sort([(5 - Type) * 100 + Id || #{id := Id, type := Type} <- L2])),
  if
    N1 > M1 -> 1;
    N1 < M1 -> 0;
    N2 > M2 -> 1;
    N2 < M2 -> 0;
    N3 > M3 -> 1;
    N3 < M3 -> 0;
    N4 > M4 -> 1;
    N4 < M4 -> 0;
    N5 > M5 -> 1;
    N5 < M5 -> 0
  end.
