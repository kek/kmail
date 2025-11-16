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
                {201, ConsumerBody, _} = test_helpers:http_post("/mailbox", <<>>),
                #{~"id" := ID, ~"password" := _Password} = json:decode(ConsumerBody),

                % Use sender API to send
                SendPackagePath = binary_to_list(<<"/mailbox/", ID/binary, "/package/from/kalle">>),
                {201, _Body, _Headers} =
                    test_helpers:http_post(
                        SendPackagePath,
                        ~"Hello",
                        [{~"Content-Type", ~"text/plain"}]
                    ),

                % Use consumer API to get list of packages
                GetPackagesPath = binary_to_list(<<"/mailbox/", ID/binary, "/packages">>),
                {200, PackageList, _RespHeaders1} = test_helpers:http_get(GetPackagesPath),
                ?assertMatch(
                    [
                        #{
                            ~"fileType" := <<"text/plain">>,
                            ~"id" := _,
                            ~"links" := #{~"download" := _},
                            ~"paid" := false,
                            ~"sender" := <<"kalle">>
                        }
                    ],
                    json:decode(PackageList)
                ),

                % Download the file
                [#{~"links" := #{~"download" := DownloadLink}}] = json:decode(PackageList),
                {200, Download, DownloadRespHeaders} = test_helpers:http_get(
                    binary_to_list(DownloadLink)
                ),
                {~"Content-Type", ContentType} = lists:keyfind(
                    ~"Content-Type", 1, DownloadRespHeaders
                ),
                ?assertEqual(~"text/plain", ContentType),
                ?assertEqual(~"Hello", Download)
            end}
            % TODO: Validate that we use the correct password.
        ]
    end}.
