-module(test_helpers).

-export([http_get/1, http_post/2, start_repo/0, http_post/3, start_web_server/0]).

http_get(Path) ->
    http_request(<<>>, Path, get, []).

http_post(Path, Payload, Headers) ->
    http_request(Payload, Path, post, Headers).

http_post(Path, Payload) ->
    http_request(Payload, Path, post, []).

http_request(Payload, Path, Method, Headers) ->
    Options = [],
    Base = "http://localhost:44000",
    URL = lists:concat([Base, Path]),
    {ok, StatusCode, RespHeaders, ClientRef} =
        hackney:request(Method, URL, Headers, Payload, Options),
    {ok, Body} = hackney:body(ClientRef),
    {StatusCode, Body, RespHeaders}.

start_repo() ->
    case whereis(repo) of
        undefined ->
            {ok, _} = repo:start_link(~"kmail_test", [{name, repo}]),
            ok;
        _ ->
            ok
    end.

start_web_server() ->
    {ok, ElliPid} = elli:start_link([{callback, web_server}, {port, 44000}]),
    ElliPid.
