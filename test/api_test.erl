-include_lib("eunit/include/eunit.hrl").
-module(api_test).

setup() ->
    application:ensure_all_started(hackney),
    ElliPid = test_helpers:start_web_server(),
    {ElliPid}.

teardown({ElliPid}) ->
    exit(ElliPid, normal),
    ok.

web_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"start page", fun() ->
                {StatusCode, _Body, RespHeaders} = test_helpers:http_get("/"),
                {~"Content-Type", ContentType} = lists:keyfind(~"Content-Type", 1, RespHeaders),
                ?assertEqual(200, StatusCode),
                ?assertEqual(~"text/html; charset=utf-8", ContentType)
            end}
        ]
    end}.
