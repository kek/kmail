-module(mailbox).

-export([create/1, contents/2, create/0, deliver/3, find_package/3]).

-type repo() :: atom().

-spec create() -> #{'id' := binary(), 'packages' := [], 'password' := binary()}.
create() -> create(repo).

-spec create(repo()) -> #{'id' := binary(), 'packages' := [], 'password' := binary()}.
create(Repo) ->
    ID = integer_to_binary(rand:uniform(1000000000)),
    Password = integer_to_binary(rand:uniform(1000000000)),
    Mailbox = #{id => ID, password => Password, packages => []},
    ok = repo:store(Repo, ID, Mailbox),
    Mailbox.

% -spec contents(repo(), binary()) -> {ok, [package()]} | {error, notfound}.
contents(Repo, RecipientID) ->
    case repo:retrieve(Repo, RecipientID) of
        {error, notfound} ->
            {error, notfound};
        {ok, #{packages := Packages}} when is_list(Packages) ->
            {ok,
                lists:map(
                    fun(#{id := ID, sender := Sender, fileType := FileType}) when is_binary(ID) ->
                        #{
                            ~"id" => ID,
                            ~"sender" => Sender,
                            ~"fileType" => FileType,
                            ~"paid" => false,
                            ~"links" => #{
                                ~"download" =>
                                    <<"/mailbox/", RecipientID/binary, "/packages/", ID/binary>>
                            }
                        }
                    end,
                    Packages
                )}
    end.

% -spec deliver(repo(), package(), binary()) -> ok.
deliver(Repo, Package, RecipientID) ->
    case repo:retrieve(Repo, RecipientID) of
        {ok, #{password := Password, packages := Packages}} when is_list(Packages) ->
            PackageWithID = Package#{id => generate_id()},
            NewPackages = [PackageWithID | Packages],
            repo:store(Repo, RecipientID, #{
                password => Password, packages => NewPackages
            }),
            ok
    end.

find_package(Repo, RecipientID, PackageID) ->
    case repo:retrieve(Repo, RecipientID) of
        {ok, #{packages := Packages}} when is_list(Packages) ->
            {value, Value} = lists:search(
                fun(Package) ->
                    case Package of
                        #{id := PackageID} -> true;
                        _ -> false
                    end
                end,
                Packages
            ),
            {ok, Value}
    end.

generate_id() ->
    integer_to_binary(rand:uniform(1000000000)).
