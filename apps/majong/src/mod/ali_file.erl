%%%-------------------------------------------------------------------
%%% @author cyy
%%% @copyright (C) 2017, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 16. 七月 2017 下午4:14
%%%-------------------------------------------------------------------
-module(ali_file).
-author("cyy").
-define(AccessKeyId, "LTAIH4Ly2IlqH4oi").
-define(AccessSecret, "7ALPiiNdKlK7R47GwfiacBE0IzSPuc").

%% API
-export([
  upload/1
]).

upload(Bin) ->
  upload("majong", Bin).

upload(Bucket, FileName) ->
  upload(Bucket, FileName, 0).

upload(Bucket, Bin, Time) ->
  Body = Bin,
  lager:info("bin size : ~p", [byte_size(Bin)]),
  File = dhcrypt:md5(Bin),
  Gmt = gmt(),

  Data = "PUT\n" ++ "\n" ++ "application/octet-stream\n" ++ Gmt ++ "\n"
    ++ "x-oss-object-acl:public-read\n" ++ "/" ++ Bucket ++ "/" ++ File,
  Sign = base64:encode(crypto:hmac(sha, ?AccessSecret, list_to_binary(Data))),

  Authorization = "OSS " ++ ?AccessKeyId ++ ":" ++ binary_to_list(Sign),

  Url = "http://" ++ Bucket ++ ".oss-cn-shanghai.aliyuncs.com" ++ "/" ++ File ,
  Host =  Bucket ++ ".oss-cn-shanghai.aliyuncs.com",
  Headers = [{"Date", Gmt}, {"Content-Type", "application/octet-stream"},
    {"x-oss-object-acl", "public-read"}, {"Authorization", Authorization}, {"Host", Host}],

  case ibrowse:send_req(Url, Headers, put, Body, [], 60000) of
    {ok, "200", _, _} -> list_to_binary(Url);
    {_, Code, RespHeader, RespBody} ->
      lager:info("Code: ~p, Header: ~p, RespBody: ~p", [Code, RespHeader, RespBody]),
      if
        Time > 0 -> upload(Bucket, File, Time - 1);
        true -> throw({Code, RespHeader, RespBody})
      end
  end.

gmt() ->
  {{Y, M, Day}, {H, Min, S}} = calendar:universal_time(),
  WeekDay = day(calendar:day_of_the_week({Y, M, Day})),
  WeekDay ++ " " ++ int2list(Day) ++ " " ++ month_to_list(M) ++ " " ++ int2list(Y)
    ++ " " ++ int2list(H) ++ ":" ++ int2list(Min) ++ ":" ++ int2list(S) ++ " GMT".


int2list(Int) when Int < 10 -> "0" ++ integer_to_list(Int);
int2list(Int) -> integer_to_list(Int).



day(1) -> "Mon,";
day(2) -> "Tue,";
day(3) -> "Wed,";
day(4) -> "Thu,";
day(5) -> "Fri,";
day(6) -> "Sat,";
day(7) -> "Sun,".

month_to_list(1) -> "Jan";
month_to_list(2) -> "Feb";
month_to_list(3) -> "Mar";
month_to_list(4) -> "Apr";
month_to_list(5) -> "May";
month_to_list(6) -> "Jun";
month_to_list(7) -> "Jul";
month_to_list(8) -> "Aug";
month_to_list(9) -> "Sep";
month_to_list(10) -> "Oct";
month_to_list(11) -> "Nov";
month_to_list(12) -> "Dec".
