-module(http_helpers).

-export([http_get/1, http_post/2]).

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
    Base = "http://localhost:44000",
    URL = lists:concat([Base, Path]),
    {ok, StatusCode, RespHeaders, ClientRef} =
        hackney:request(Method, URL, Headers, Payload, Options),
    {ok, Body} = hackney:body(ClientRef),
    {StatusCode, Body, RespHeaders}.
