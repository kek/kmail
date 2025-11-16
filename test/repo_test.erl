-include_lib("eunit/include/eunit.hrl").
-module(repo_test).

setup() ->
    {ok, Repo} = repo:start_link(~"kmail_repo_test", []),
    Repo.

teardown(_Repo) ->
    {ok, Conn} = riakc_pb_socket:start("127.0.0.1", 8087),
    Bucket = ~"kmail_repo_test",
    {ok, Keys} = riakc_pb_socket:list_keys(Conn, Bucket),
    lists:foreach(
        fun(Key) ->
            ok = riakc_pb_socket:delete(Conn, Bucket, Key)
        end,
        Keys
    ),
    ok.

repo_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(Repo) ->
        [
            {"when storing a value, it can be retrieved later", fun() ->
                ok = repo:store(Repo, "Hey", "There"),
                {ok, Value} = repo:retrieve(Repo, "Hey"),
                ?assertEqual("There", Value)
            end},
            {"when trying to retrieve a value that doesn't exist, we get an error", fun() ->
                Result = repo:retrieve(Repo, "nonexistent key"),
                ?assertEqual({error, notfound}, Result)
            end}
        ]
    end}.
