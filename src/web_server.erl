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
handle('GET', [~"mailbox", ID, ~"packages"], _Req) ->
    case repo:retrieve(repo, ID) of
        {error, notfound} ->
            json_error(404, ~"No such mailbox ID");
        {ok, _Value} ->
            {200, [], json:encode([])}
    end;
handle('POST', [~"mailbox"], _Req) ->
    Consumer = mailbox:create(),
    Body = json:encode(Consumer),
    Headers = [{"Content-Type", "application/json"}],
    {201, Headers, Body};
handle('POST', [~"mailbox", RecipientID, ~"package", ~"from", _SenderID], _Req) ->
    case repo:retrieve(repo, RecipientID) of
        {ok, _} -> json_response(201, #{});
        {error, notfound} -> json_error(404, ~"Recipient not found")
    end;
handle(_Method, _Path, _Req) ->
    json_error(404, ~"Unknown request").

handle_event(elli_startup, [], undefined) ->
    logger:info("Web server starting.~n~n");
handle_event(request_error, [Req, Error, Stacktrace], _Args) ->
    ErrorInfo = [
        Error, printable_headers(Req), Stacktrace
    ],
    logger:error("*** ~p error ***~n~nHeaders:~n~s~nStacktrace:~n~p~n~n", ErrorInfo),
    % erl_error:format_exception(error, Error, Stacktrace)
    ok;
handle_event(
    request_complete,
    [Req, Status, _Headers, _ResponseBody, {_Timers, _Lengths}],
    _
) ->
    Metadata = [human_time(), Req#req.method, [~"/" | Req#req.path], Status],
    logger:info("~s ~s ~s -> ~p~n", Metadata),
    ok;
handle_event(request_closed, Data, Args) ->
    logger:warning("~s request closed: ~p ~p~n", [human_time(), Data, Args]),
    ok;
handle_event(Event, Data, Args) ->
    logger:warning("*** Unknown event ~p ***~nData: ~p~nArgs: ~p~n", [Event, Data, Args]),
    ok.

human_time() ->
    {H, M, S} = time(),
    io_lib:format("~.2.0w:~.2.0w:~.2.0w", [H, M, S]).

render_template(Template, Params) ->
    case code:priv_dir(kmail) of
        PrivDir when is_list(PrivDir) ->
            TemplatePath = filename:join([PrivDir, "templates", Template]),
            {ok, Bin} = file:read_file(TemplatePath),
            Body = bbmustache:render(Bin, Params),
            Body
    end.

printable_headers(Req) ->
    Headers = Req#req.headers,
    io_lib:format("~p~n", [Headers]).

json_response(StatusCode, Data) ->
    {StatusCode, [{"Content-Type", "application/json"}], json:encode(Data)}.

json_error(StatusCode, ErrorMessage) ->
    {StatusCode, [{"Content-Type", "application/json"}], json:encode(#{error => ErrorMessage})}.
