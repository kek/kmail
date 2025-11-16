-module(consumer).

-export([create/0]).

create() ->
    ID = integer_to_binary(rand:uniform(1000)),
    Password = integer_to_binary(rand:uniform(1000)),
    ok = repo:store(repo, ID, Password),
    #{id => ID, password => Password}.
