%% -*- coding: utf-8 -*-
%% Automatically generated, do not edit
%% Generated by gpb_compile version 3.26.8

-ifndef(majong_pb).
-define(majong_pb, true).

-define(majong_pb_gpb_version, "3.26.8").

-ifndef('REQ_JOIN_PB_H').
-define('REQ_JOIN_PB_H', true).
-record(req_join,
        {id                             % = 1, int32
        }).
-endif.

-ifndef('REQ_LOGIN_PB_H').
-define('REQ_LOGIN_PB_H', true).
-record(req_login,
        {code,                          % = 1, string (optional)
         channel,                       % = 2, int32 (optional)
         user_id                        % = 3, int32 (optional)
        }).
-endif.

-ifndef('RSP_CREATE_ROOM_PB_H').
-define('RSP_CREATE_ROOM_PB_H', true).
-record(rsp_create_room,
        {status,                        % = 1, sint32
         room_id,                       % = 2, int32 (optional)
         coins                          % = 3, int32 (optional)
        }).
-endif.

-ifndef('REQ_READY_PB_H').
-define('REQ_READY_PB_H', true).
-record(req_ready,
        {type                           % = 1, int32
        }).
-endif.

-ifndef('REQ_ZHUANG_PB_H').
-define('REQ_ZHUANG_PB_H', true).
-record(req_zhuang,
        {
        }).
-endif.

-ifndef('RSP_GAME_START_PB_H').
-define('RSP_GAME_START_PB_H', true).
-record(rsp_game_start,
        {uid                            % = 1, int32 (optional)
        }).
-endif.

-ifndef('RSP_START_PB_H').
-define('RSP_START_PB_H', true).
-record(rsp_start,
        {status                         % = 1, sint32
        }).
-endif.

-ifndef('PB_ROOM_INFO_PB_H').
-define('PB_ROOM_INFO_PB_H', true).
-record(pb_room_info,
        {room_id,                       % = 1, int32
         owner,                         % = 2, int32
         round,                         % = 3, int32
         pay,                           % = 4, int32
         banker,                        % = 5, int32
         special,                       % = 6, int32
         type                           % = 7, int32
        }).
-endif.

-ifndef('PB_PLAYER_PB_H').
-define('PB_PLAYER_PB_H', true).
-record(pb_player,
        {name,                          % = 1, string
         uid,                           % = 2, int32
         coins,                         % = 3, int32
         logo,                          % = 4, string
         owner,                         % = 5, int32 (optional)
         index                          % = 6, int32
        }).
-endif.

-ifndef('RSP_JOIN_PB_H').
-define('RSP_JOIN_PB_H', true).
-record(rsp_join,
        {status,                        % = 1, sint32
         players = [],                  % = 2, [{msg,pb_player}]
         room_info                      % = 3, {msg,pb_room_info} (optional)
        }).
-endif.

-ifndef('RSP_PLAYER_ZHUANG_PB_H').
-define('RSP_PLAYER_ZHUANG_PB_H', true).
-record(rsp_player_zhuang,
        {uid                            % = 1, int32
        }).
-endif.

-ifndef('RSP_ZHUANG_PB_H').
-define('RSP_ZHUANG_PB_H', true).
-record(rsp_zhuang,
        {status                         % = 1, sint32
        }).
-endif.

-ifndef('RSP_PLAYER_LEAVE_PB_H').
-define('RSP_PLAYER_LEAVE_PB_H', true).
-record(rsp_player_leave,
        {uid                            % = 1, int32
        }).
-endif.

-ifndef('RSP_LEAVE_PB_H').
-define('RSP_LEAVE_PB_H', true).
-record(rsp_leave,
        {status                         % = 1, sint32
        }).
-endif.

-ifndef('RSP_PLAYER_SCORE_PB_H').
-define('RSP_PLAYER_SCORE_PB_H', true).
-record(rsp_player_score,
        {uid,                           % = 1, int32
         score                          % = 2, int32
        }).
-endif.

-ifndef('RSP_SCORE_PB_H').
-define('RSP_SCORE_PB_H', true).
-record(rsp_score,
        {status                         % = 1, int32
        }).
-endif.

-ifndef('RSP_ZHUANG_END_PB_H').
-define('RSP_ZHUANG_END_PB_H', true).
-record(rsp_zhuang_end,
        {uid                            % = 1, int32
        }).
-endif.

-ifndef('RSP_NEW_PLAYER_PB_H').
-define('RSP_NEW_PLAYER_PB_H', true).
-record(rsp_new_player,
        {player                         % = 1, {msg,pb_player}
        }).
-endif.

-ifndef('RSP_LOGIN_PB_H').
-define('RSP_LOGIN_PB_H', true).
-record(rsp_login,
        {status,                        % = 1, sint32
         coins,                         % = 2, int32 (optional)
         gems                           % = 3, int32 (optional)
        }).
-endif.

-ifndef('REQ_CREATE_ROOM_PB_H').
-define('REQ_CREATE_ROOM_PB_H', true).
-record(req_create_room,
        {round,                         % = 1, int32
         pay,                           % = 2, int32
         banker,                        % = 3, int32
         special,                       % = 4, int32
         type                           % = 5, int32
        }).
-endif.

-ifndef('RSP_PLAYER_READY_PB_H').
-define('RSP_PLAYER_READY_PB_H', true).
-record(rsp_player_ready,
        {uid,                           % = 1, int32
         type                           % = 2, int32
        }).
-endif.

-ifndef('RSP_READY_PB_H').
-define('RSP_READY_PB_H', true).
-record(rsp_ready,
        {status                         % = 1, sint32
        }).
-endif.

-ifndef('RSP_RESULT_PB_H').
-define('RSP_RESULT_PB_H', true).
-record(rsp_result,
        {
        }).
-endif.

-ifndef('REQ_START_PB_H').
-define('REQ_START_PB_H', true).
-record(req_start,
        {
        }).
-endif.

-ifndef('REQ_SCORE_PB_H').
-define('REQ_SCORE_PB_H', true).
-record(req_score,
        {score                          % = 1, int32
        }).
-endif.

-ifndef('REQ_LEAVE_PB_H').
-define('REQ_LEAVE_PB_H', true).
-record(req_leave,
        {uid                            % = 1, int32
        }).
-endif.

-ifndef('RSP_PUB_PB_H').
-define('RSP_PUB_PB_H', true).
-record(rsp_pub,
        {status,                        % = 1, sint32
         pub                            % = 2, string (optional)
        }).
-endif.

-ifndef('REQ_PUB_PB_H').
-define('REQ_PUB_PB_H', true).
-record(req_pub,
        {
        }).
-endif.

-endif.
