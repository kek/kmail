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
    Data = #{},
    Template = "index.html",
    Body = render_template(Template, Data),
    Headers = [{"Content-Type", "text/html; charset=utf-8"}],
    {StatusCode, Headers, Body};
handle('GET', [~"share", _ID], _Req) ->
    {200, [], ~"[]"};
handle(_Method, _Path, _Req) ->
    {404, [], ~"Not Found"}.

handle_event(request_error, [Req, Error, Stacktrace], _Args) ->
    io:format("*** ~p error ***~n~nHeaders:~n~s~nStacktrace:~n~p~n~n", [
        Error, printable_headers(Req), Stacktrace
    ]),
    ok;
handle_event(
    request_complete,
    [Req, Status, _Headers, _ResponseBody, {_Timers, _Lengths}],
    _
) ->
    log_result(Req, Status),
    ok;
handle_event(request_closed, _Data, _Args) ->
    ok;
handle_event(Event, Data, Args) ->
    io:format("*** Unknown event ~p ***~nData: ~p~nArgs: ~p~n", [Event, Data, Args]),
    ok.

human_time() ->
    {H, M, S} = time(),
    io_lib:format("~.2.0w:~.2.0w:~.2.0w", [H, M, S]).

path_join(Path) ->
    binary:join([~"/" | Path], ~"/").

render_template(Template, Params) ->
    TemplateBase = ~"src/templates/",
    TemplateBinary = list_to_binary(Template),
    TemplatePath = <<TemplateBase/binary, TemplateBinary/binary>>,
    {ok, Bin} = file:read_file(TemplatePath),
    Body = bbmustache:render(Bin, Params),
    Body.

printable_headers(Req) ->
    Headers = Req#req.headers,
    io_lib:format("~p~n", [Headers]).

log_result(Req, Result) ->
    Method = Req#req.method,
    Path = path_join(Req#req.path),
    io:format("~s ~s ~s -> ~p~n", [human_time(), Method, Path, Result]).
