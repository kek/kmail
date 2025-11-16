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
                % Use sender API to send
                % Use consumer API to receive
                ?assert(true)
            end}
        ]
    end}.
