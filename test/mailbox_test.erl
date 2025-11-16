-include_lib("eunit/include/eunit.hrl").
-module(mailbox_test).

setup() ->
    {ok, Repo} = repo:start_link(~"kmail_mailbox_test", []),
    Repo.

teardown(_Repo) ->
    test_helpers:clear_bucket(~"kmail_mailbox_test"),
    ok.

mailbox_test_() ->
    {setup, fun setup/0, fun teardown/1, fun(Repo) ->
        [
            {"reading nonexistant mailbox renders error", fun() ->
                ?assertMatch({error, notfound}, mailbox:contents(Repo, "nonexistant_mailbox"))
            end},
            {"after creating a mailbox, it is empty", fun() ->
                #{id := ID} = mailbox:create(Repo),
                {ok, Packages} = mailbox:contents(Repo, ID),
                ?assertEqual([], Packages)
            end},
            {"after putting a package to a mailbox, it contains that package", fun() ->
                #{id := RecipientID} = mailbox:create(Repo),
                Package = #{
                    fileType => "text/plain", payload => "Merry Christmas!", sender => "Santa Claus"
                },
                ok = mailbox:deliver(Repo, Package, RecipientID),
                Package2 = #{
                    fileType => "text/plain",
                    payload => "And a happy new year!",
                    sender => "Santa Claus"
                },
                ok = mailbox:deliver(Repo, Package2, RecipientID),
                {ok, Packages} = mailbox:contents(Repo, RecipientID),
                ?assertNotEqual([], Packages)
            end}
        ]
    end}.

% TODO: Test Deliver to nonexistant mailbox
