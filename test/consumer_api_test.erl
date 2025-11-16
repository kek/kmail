-include_lib("eunit/include/eunit.hrl").
-module(consumer_api_test).

setup() ->
    application:ensure_all_started(hackney),
    ok = test_helpers:start_repo(),
    ElliPid = test_helpers:start_web_server(),
    {ElliPid}.

teardown({ElliPid}) ->
    exit(ElliPid, normal),
    ok.

consumer_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"Registering a mailbox generates an ID and a password", fun() ->
                {StatusCode, Body, RespHeaders} = test_helpers:http_post("/mailbox", <<>>),
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
            {"Getting the list of packages in a mailbox that does not exist renders 404", fun() ->
                {StatusCode, Body, _RespHeaders} = test_helpers:http_get(
                    "/mailbox/999999/packages"
                ),
                ?assertEqual(404, StatusCode),
                ?assertEqual(#{~"error" => ~"No such mailbox ID"}, json:decode(Body))
            end},
            {"Listing packages for a newly registered mailbox renders an empty list", fun() ->
                {201, Body, _RespHeaders} = test_helpers:http_post("/mailbox", <<>>),
                #{~"id" := ID, ~"password" := _Password} = json:decode(Body),
                Path = io_lib:format("/mailbox/~s/packages", [ID]),
                {StatusCode1, Body1, _RespHeaders1} = test_helpers:http_get(Path),
                ?assertEqual(200, StatusCode1),
                ?assertEqual([], json:decode(Body1))
            end}
        ]
    end}.
