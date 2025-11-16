-module(web_server).
-behaviour(elli_handler).

-include_lib("elli/include/elli.hrl").

-export([handle/2, handle_event/3]).

handle(Req, _Args) ->
    Method = Req#req.method,
    Path = elli_request:path(Req),
    handle(Method, Path, Req).

handle('GET' = _Method, [] = _Path, _Req) ->
    StatusCode = ok,
    Headers = [{"Content-Type", "text/plain; charset=utf-8"}],
    Body = ~"🐻",
    {StatusCode, Headers, Body};
handle('GET', [~"share", _ID], _Req) ->
    {200, [], ~"[]"};
handle(_Method, _Path, _Req) ->
    {404, [], ~"Not Found"}.

handle_event(_Event, _Data, _Args) ->
    ok.
