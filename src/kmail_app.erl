%%%-------------------------------------------------------------------
%% @doc kmail public API
%% @end
%%%-------------------------------------------------------------------

-module(kmail_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    kmail_sup:start_link().

stop(_State) ->
    ok.

%% internal functions
