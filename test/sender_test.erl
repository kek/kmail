-include_lib("eunit/include/eunit.hrl").
-module(sender_test).

setup() ->
    application:ensure_all_started(hackney),
    {ok, Pid} = elli:start_link([{callback, web_server}, {port, 44002}]),
    Pid.

teardown(Pid) ->
    exit(Pid, normal),
    ok.

consumer_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(_Pid) ->
        [
            {"TODO", fun() ->
                ?assert(true)
            end}
        ]
    end}.
