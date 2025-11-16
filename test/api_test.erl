-include_lib("eunit/include/eunit.hrl").
-module(api_test).

setup() ->
    application:ensure_all_started(hackney),
    {ok, Pid} = elli:start_link([{callback, web_server}, {port, 44000}]),
    Pid.

teardown(Pid) ->
    exit(Pid, normal),
    ok.

web_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"start page", fun() ->
                {StatusCode, _Body, RespHeaders} = http_get("/"),
                {~"Content-Type", ContentType} = lists:keyfind(~"Content-Type", 1, RespHeaders),
                ?assertEqual(200, StatusCode),
                ?assertEqual(~"text/html; charset=utf-8", ContentType)
            end}
        ]
    end}.

http_get(Path) ->
    Method = get,
    Payload = <<>>,
    http_request(Payload, Path, Method).

http_request(Payload, Path, Method) ->
    Headers = [],
    Options = [],
    {ok, StatusCode, RespHeaders, ClientRef} = hackney:request(
        Method, lists:concat(["http://localhost:44000", Path]), Headers, Payload, Options
    ),
    {ok, Body} = hackney:body(ClientRef),
    {StatusCode, Body, RespHeaders}.
