-include_lib("eunit/include/eunit.hrl").
-module(consumer_test).

setup() ->
    application:ensure_all_started(hackney),
    {ok, RepoPid} = repo:start_link(~"kmail_test", [{name, repo}]),
    {ok, ElliPid} = elli:start_link([{callback, web_server}, {port, 44000}]),
    {RepoPid, ElliPid}.

teardown({RepoPid, ElliPid}) ->
    exit(RepoPid, normal),
    exit(ElliPid, normal),
    ok.

consumer_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"Registering a consumer generates an ID and a password", fun() ->
                {StatusCode, Body, RespHeaders} = http_helpers:http_post("/consumer", <<>>),
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
            {"Getting the list of shares for a consumer that does not exist renders 404", fun() ->
                {StatusCode, Body, _RespHeaders} = http_helpers:http_get("/share/1"),
                ?assertEqual(404, StatusCode),
                ?assertEqual(#{~"error" => ~"No such consumer ID"}, json:decode(Body))
            end},
            {"Listing shares for a newly registered consumer renders an empty list", fun() ->
                {201, Body, _RespHeaders} = http_helpers:http_post("/consumer", <<>>),
                #{~"id" := ID, ~"password" := _Password} = json:decode(Body),
                Path = io_lib:format("/share/~s", [ID]),
                {StatusCode1, Body1, _RespHeaders1} = http_helpers:http_get(Path),
                ?assertEqual(200, StatusCode1),
                ?assertEqual([], json:decode(Body1))
            end}
        ]
    end}.
