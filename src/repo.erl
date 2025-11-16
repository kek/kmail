-module(repo).

-export([store/3]).
-export([retrieve/2]).
-export([start_link/1]).

-export([init/1, handle_call/3, handle_cast/2]).

-behaviour(gen_server).

%% API

start_link(Bucket) ->
    gen_server:start_link(repo, [Bucket], []).

store(Pid, Key, Value) ->
    gen_server:call(Pid, {store, Key, Value}).

retrieve(Pid, Key) ->
    gen_server:call(Pid, {retrieve, Key}).

%% Callbacks for `gen_server`

init([Bucket]) ->
    {ok, Conn} = riakc_pb_socket:start("127.0.0.1", 8087),
    {ok, {Conn, Bucket}}.

handle_call({store, Key, Value}, _From, {Riak, Bucket} = State) ->
    Object = riakc_obj:new(Bucket, term_to_binary(Key), Value),
    riakc_pb_socket:put(Riak, Object),
    {reply, ok, State};
handle_call({retrieve, Key}, _From, {Pid, MyBucket} = State) ->
    Result =
        case riakc_pb_socket:get(Pid, MyBucket, term_to_binary(Key)) of
            {ok, Fetched} ->
                Binary = riakc_obj:get_value(Fetched),
                Value = binary_to_term(Binary),
                {ok, Value};
            {error, notfound} ->
                {error, notfound}
        end,
    {reply, Result, State}.

handle_cast(_Request, _State) ->
    erlang:error(not_implemented).
