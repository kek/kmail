-include_lib("eunit/include/eunit.hrl").
-module(sender_test).

-export([setup/0, teardown/1]).

setup() ->
    application:ensure_all_started(hackney),
    ok = test_helpers:start_repo(),
    ElliPid = test_helpers:start_web_server(),
    {ElliPid}.

teardown({ElliPid}) ->
    exit(ElliPid, normal),
    ok.

sender_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"Sending content to nonexistant recipient", fun() ->
                Path = binary_to_list(~"/mailbox/0/package/from/kalle"),
                {StatusCode, Body, _RespHeaders} =
                    test_helpers:http_post(
                        Path,
                        ~"Hello",
                        [{"Content-Type", "text/plain"}]
                    ),
                ?assertEqual(404, StatusCode),
                ?assertEqual(#{~"error" => ~"Recipient not found"}, json:decode(Body))
            end},
            {"Sending content", fun() ->
                #{id := ID} = consumer:create(),
                Path = binary_to_list(<<"/mailbox/", ID/binary, "/package/from/kalle">>),
                {StatusCode, _Body, _Headers} =
                    test_helpers:http_post(
                        Path,
                        ~"Hello",
                        [{"Content-Type", "text/plain"}]
                    ),
                ?assertEqual(201, StatusCode)
            end}
        ]
    end}.
