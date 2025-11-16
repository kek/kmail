-include_lib("eunit/include/eunit.hrl").
-module(kmail_test).

a_test() ->
    ok = repo:store("Hey", "There"),
    {ok, Value} = repo:retrieve("Hey"),
    "There" = Value.
