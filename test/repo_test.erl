-include_lib("eunit/include/eunit.hrl").
-module(repo_test).

setup() ->
    {ok, Repo} = repo:start_link(~"kmail_repo_test", []),
    Repo.

teardown(_Repo) ->
    test_helpers:clear_bucket(~"kmail_repo_test"),
    ok.

repo_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(Repo) ->
        [
            {"when storing a value, it can be retrieved later", fun() ->
                ok = repo:store(Repo, "Hey", "There"),
                {ok, Value} = repo:retrieve(Repo, "Hey"),
                ?assertEqual("There", Value)
            end},
            {"we can store a list", fun() ->
                ok = repo:store(Repo, "List", []),
                {ok, Value} = repo:retrieve(Repo, "List"),
                ?assertEqual([], Value)
            end},
            {"when trying to retrieve a value that doesn't exist, we get an error", fun() ->
                Result = repo:retrieve(Repo, "nonexistent key"),
                ?assertEqual({error, notfound}, Result)
            end}
        ]
    end}.
