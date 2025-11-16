-include_lib("eunit/include/eunit.hrl").
-module(integration_test).

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
            {"Sending content from sender to recipient", fun() ->
                % Register consumer
                {201, ConsumerBody, _} = test_helpers:http_post("/consumer", <<>>),
                #{~"id" := ID, ~"password" := _Password} = json:decode(ConsumerBody),

                % Use sender API to send
                SendContentPath = binary_to_list(<<"/share/nonpayable/from/kalle/to/", ID/binary>>),
                {201, _Body, _Headers} =
                    test_helpers:http_post(
                        SendContentPath,
                        ~"Hello",
                        [{"Content-Type", "text/plain"}]
                    ),

                % Use consumer API to get list of packages
                GetSharesPath = binary_to_list(<<"/share/", ID/binary>>),
                {200, ShareList, _RespHeaders1} = test_helpers:http_get(GetSharesPath),
                ?assertNotEqual([], json:decode(ShareList))

            % TODO: Validate that we use the correct password.
            % TODO: Get the first available package and assert that says "Hello".
            end}
        ]
    end}.
