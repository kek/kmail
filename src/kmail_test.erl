-include_lib("eunit/include/eunit.hrl").
-module(kmail_test).

'when storing a value, it can be retrieved later   _test'() ->
    ok = repo:store("Hey", "There"),
    {ok, Value} = repo:retrieve("Hey"),
    "There" = Value.

'when trying to retrieve a value that doesn\'t exist, we get an error   _test'() ->
    ?assertEqual({error, notfound}, repo:retrieve("nonexistent key")).
