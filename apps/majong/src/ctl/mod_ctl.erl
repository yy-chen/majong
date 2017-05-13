-module(mod_ctl).
-export([
        init/0,
        stop/0,
        start_listen/0,
        before_upgrade/1,
        after_upgrade/1
    ]).

init() ->
    lager:info("logic start"),
    start_listen(),
    ok.

start_player_sup() ->
    ChildSpec = {player_sup, {player_sup, start_link, []},
        permanent, 60000, supervisor, [player_sup]},
    supervisor:start_child(dr2_logic_sup, ChildSpec).

start_listen() ->
    SockOpt = [binary, {packet, 2}, {active, true}, {reuseaddr, true}, {nodelay, true},
        {delay_send, false}, {send_timeout, 5000}, {keepalive, true}, {ip, {0,0,0,0}}],
    {ok, _} = dhtcp:start(6667, SockOpt, 10, {supervisor, start_child, [player_sup, []]}, agent),
    lager:info("tcp listen  ok").

stop() ->
    ok.
before_upgrade(_Lv) -> ok.
after_upgrade(_Lv) -> ok.
