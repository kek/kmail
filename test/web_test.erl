-include_lib("eunit/include/eunit.hrl").
-module(web_test).

setup() ->
    application:ensure_all_started(hackney),
    {ok, Pid} = elli:start_link([{callback, web_server}, {port, 44000}]),
    Pid.

teardown(Pid) ->
    exit(Pid, normal),
    ok.

repo_test_() ->
    {setup, fun setup/0, fun teardown/1, fun (_Pid) ->
        [
            {"whatvere", fun () ->
            Method = get,
            URL = <<"http://localhost:44000">>,
            Headers = [],
            Payload = <<>>,
            Options = [],
            {ok, StatusCode, _RespHeaders, ClientRef} = hackney:request(Method, URL, Headers, Payload, Options),

            {ok, Body} = hackney:body(ClientRef),
                ?assertEqual(200,StatusCode),
                ?assertEqual(~"🐻", Body)
            end}
        ]
    end}.
