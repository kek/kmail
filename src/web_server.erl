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
    {200, [], ~([])};
handle('POST', [~"consumer"], _Req) ->
    Consumer = consumer:create(),
    Body = iolist_to_binary(json:encode(Consumer)),
    Headers = [{"Content-Type", "application/json"}],
    {201, Headers, Body};
handle(_Method, _Path, _Req) ->
    {404, [], ~"Not Found"}.

handle_event(elli_startup, [], undefined) ->
    io:format("Web server starting.~n~n");
handle_event(request_error, [Req, Error, Stacktrace], _Args) ->
    ErrorInfo = [
        Error, printable_headers(Req), Stacktrace
    ],
    io:format("*** ~p error ***~n~nHeaders:~n~s~nStacktrace:~n~p~n~n", ErrorInfo),
    % erl_error:format_exception(error, Error, Stacktrace)
    ok;
handle_event(
    request_complete,
    [Req, Status, _Headers, _ResponseBody, {_Timers, _Lengths}],
    _
) ->
    Metadata = [human_time(), Req#req.method, [~"/" | Req#req.path], Status],
    io:format("~s ~s ~s -> ~p~n", Metadata),
    ok;
handle_event(request_closed, _Data, _Args) ->
    ok;
handle_event(Event, Data, Args) ->
    io:format("*** Unknown event ~p ***~nData: ~p~nArgs: ~p~n", [Event, Data, Args]),
    ok.

human_time() ->
    {H, M, S} = time(),
    io_lib:format("~.2.0w:~.2.0w:~.2.0w", [H, M, S]).

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
