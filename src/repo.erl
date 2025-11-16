-module(repo).

-export([store/3]).
-export([retrieve/2]).
-export([start/0]).

start() ->
    {ok, 1}.

store(_, Key, Value) ->
    {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 8087),
    MyBucket = ~"kmails",
    Object = riakc_obj:new(MyBucket, term_to_binary(Key), Value),
    riakc_pb_socket:put(Pid, Object).

retrieve(_, Key) ->
    {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 8087),
    MyBucket = ~"kmails",
    case riakc_pb_socket:get(Pid, MyBucket, term_to_binary(Key)) of
        {ok, Fetched} ->
            Binary = riakc_obj:get_value(Fetched),
            Value = binary_to_term(Binary),
            {ok, Value};
        {error, notfound} ->
            {error, notfound}
    end.
