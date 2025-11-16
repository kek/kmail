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
            {"reading nonexistent mailbox renders error", fun() ->
                ?assertMatch({error, notfound}, mailbox:contents(Repo, "nonexistant_mailbox"))
            end},
            {"after creating a mailbox, it is empty", fun() ->
                #{id := ID} = mailbox:create(Repo),
                {ok, Packages} = mailbox:contents(Repo, ID),
                ?assertEqual([], Packages)
            end},
            {"after putting a package in a mailbox, it contains that package", fun() ->
                #{id := RecipientID} = mailbox:create(Repo),
                Package = #{
                    fileType => "text/plain", payload => "Merry Christmas!", sender => "Santa Claus"
                },
                ok = mailbox:deliver(Repo, Package, RecipientID),
                {ok, [ReceivedPackage]} = mailbox:contents(Repo, RecipientID),
                ?assertMatch(
                    #{
                        ~"id" := _PackageID,
                        ~"fileType" := "text/plain",
                        ~"paid" := false,
                        ~"sender" := "Santa Claus",
                        ~"links" := #{
                            ~"download" := _DownloadLink
                        }
                    },
                    ReceivedPackage
                )
            end},
            {"finding a package by recipient ID and package ID", fun() ->
                #{id := RecipientID} = mailbox:create(Repo),
                SentPackage = #{
                    fileType => "text/plain", payload => "Merry Christmas!", sender => "Santa Claus"
                },
                ok = mailbox:deliver(Repo, SentPackage, RecipientID),
                {ok, [ReceivedPackage]} = mailbox:contents(Repo, RecipientID),
                #{~"id" := PackageID} = ReceivedPackage,
                {ok, Package} = mailbox:find_package(Repo, RecipientID, PackageID),
                ?assertMatch(
                    #{
                        id := _,
                        fileType := "text/plain",
                        payload := "Merry Christmas!",
                        sender := "Santa Claus"
                    },
                    Package
                )
            end}
        ]
    end}.

% TODO: Test Deliver to nonexistant mailbox
