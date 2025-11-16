-module(repo).

-export([store/2]).
-export([retrieve/1]).

store(Key, Value) ->
    {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 8087),
    MyBucket = <<"kmails">>,
    Object = riakc_obj:new(MyBucket, term_to_binary(Key), Value),
    riakc_pb_socket:put(Pid, Object).

retrieve(Key) ->
    {ok, Pid} = riakc_pb_socket:start("127.0.0.1", 8087),
    MyBucket = <<"kmails">>,
    {ok, Fetched} = riakc_pb_socket:get(Pid, MyBucket, term_to_binary(Key)),
    Binary = riakc_obj:get_value(Fetched),
    Value = binary_to_term(Binary),
    {ok, Value}.
