-include_lib("eunit/include/eunit.hrl").
-module(consumer_test).

setup() ->
    application:ensure_all_started(hackney),
    {ok, RepoPid} = repo:start_link(~"kmail", [{name, repo}]),
    {ok, ElliPid} = elli:start_link([{callback, web_server}, {port, 44001}]),
    {RepoPid, ElliPid}.

teardown({RepoPid, ElliPid}) ->
    exit(RepoPid, normal),
    exit(ElliPid, normal),
    ok.

consumer_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"Registering a consumer generates an ID and a password", fun() ->
                {StatusCode, Body, RespHeaders} = http_post("/consumer", <<>>),
                case lists:keyfind(~"Content-Type", 1, RespHeaders) of
                    {~"Content-Type", ContentType} ->
                        ?assertEqual(201, StatusCode),
                        ?assertEqual(~"application/json", ContentType),
                        ?assertMatch(#{~"id" := _, ~"password" := _}, json:decode(Body));
                    false ->
                        logger:error("~p ~p~n", [StatusCode, Body]),
                        logger:error("Didn't find Content-Type in response headers: ~p~n", [
                            RespHeaders
                        ]),
                        ?assertNot(true)
                end
            end},
            {"Getting the list of shares, when the list is empty, renders an empty list", fun() ->
                {StatusCode, Body, _RespHeaders} = http_get("/share/1"),
                ?assertEqual(200, StatusCode),
                ?assertEqual(~"[]", Body)
            end}
        ]
    end}.

http_get(Path) ->
    Method = get,
    Payload = <<>>,
    http_request(Payload, Path, Method).

http_post(Path, Payload) ->
    Method = post,
    http_request(Payload, Path, Method).

http_request(Payload, Path, Method) ->
    Headers = [],
    Options = [],
    Base = "http://localhost:44001",
    URL = lists:concat([Base, Path]),
    {ok, StatusCode, RespHeaders, ClientRef} =
        hackney:request(Method, URL, Headers, Payload, Options),
    {ok, Body} = hackney:body(ClientRef),
    {StatusCode, Body, RespHeaders}.
