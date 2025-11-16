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
            {"friendly face", fun() ->
                {StatusCode, Body} = http_get(~"http://localhost:44000"),
                ?assertEqual(200, StatusCode),
                ?assertEqual(~"🐻\n", Body)
            end},

            {"Getting the list of shares, when the list is empty, renders an empty list", fun() ->
                {StatusCode, Body} = http_get(~"http://localhost:44000/share/1"),
                ?assertEqual(200, StatusCode),
                ?assertEqual(~"[]", Body)
            end}
        ]
    end}.

http_get(URL) ->
    Method = get,
    Headers = [],
    Payload = <<>>,
    Options = [],
    {ok, StatusCode, _RespHeaders, ClientRef} = hackney:request(
        Method, URL, Headers, Payload, Options
    ),
    {ok, Body} = hackney:body(ClientRef),
    {StatusCode, Body}.
