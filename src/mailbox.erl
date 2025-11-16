-module(mailbox).

-export([create/1, contents/2, create/0, deliver/3]).

-type mailbox() :: #{id => binary(), password => binary(), packages => [term()]}.
-type repo() :: atom().

-spec create() -> mailbox().
-spec create(repo()) -> mailbox().
-spec contents(repo(), binary()) -> {ok, [term()]} | {error, notfound}.
-spec deliver(repo(), term(), binary()) -> ok.

create() -> create(repo).
create(Repo) ->
    ID = integer_to_binary(rand:uniform(1000)),
    Password = integer_to_binary(rand:uniform(1000)),
    Mailbox = #{id => ID, password => Password, packages => []},
    ok = repo:store(Repo, ID, Mailbox),
    Mailbox.

contents(Repo, RecipientID) ->
    case repo:retrieve(Repo, RecipientID) of
        {error, notfound} ->
            {error, notfound};
        {ok, #{packages := Packages}} when is_list(Packages) ->
            {ok, Packages}
    end.

deliver(Repo, Package, RecipientID) ->
    case repo:retrieve(Repo, RecipientID) of
        {ok, #{password := Password, packages := Packages}} when is_list(Packages) ->
            NewPackages = [Package | Packages],
            repo:store(Repo, RecipientID, #{password => Password, packages => NewPackages}),
            ok
    end.
