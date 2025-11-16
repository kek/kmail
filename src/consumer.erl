-module(consumer).

-export([create/0]).

-type consumer() :: #{id := binary(), password := binary()}.

-spec create() -> consumer().
create() ->
    ID = integer_to_binary(rand:uniform(1000)),
    Password = integer_to_binary(rand:uniform(1000)),
    ok = repo:store(repo, ID, Password),
    #{id => ID, password => Password}.
