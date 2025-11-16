-include_lib("eunit/include/eunit.hrl").
-module(kmail_test).

'when storing a value, it can be retrieved later   _test'() ->
    {ok, Repo} = repo:start_link(~"kmail_test"),
    ok = repo:store(Repo, "Hey", "There"),
    {ok, Value} = repo:retrieve(Repo, "Hey"),
    ?assertEqual("There", Value).

'when trying to retrieve a value that doesn\'t exist, we get an error   _test'() ->
    {ok, Repo} = repo:start_link(~"kmail_test"),
    ?assertEqual({error, notfound}, repo:retrieve(Repo, "nonexistent key")).
