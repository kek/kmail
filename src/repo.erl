-module(repo).

-export([store/3]).
-export([retrieve/2]).
-export([start_link/2]).

-export([init/1, handle_call/3, handle_cast/2]).

-behaviour(gen_server).

%% API

start_link(Bucket, Options) ->
    gen_server:start_link(repo, [Bucket, Options], []).

store(Name, Key, Value) when not is_pid(Name) ->
    case whereis(Name) of
        undefined ->
            logger:critical("repo ~p not started~n", [Name]),
            {error, "Repo not started"};
        Pid ->
            store(Pid, Key, Value)
    end;
store(Repo, Key, Value) ->
    gen_server:call(Repo, {store, Key, Value}).

retrieve(Repo, Key) ->
    gen_server:call(Repo, {retrieve, Key}).

%% Callbacks for `gen_server`

init([Bucket, Options]) ->
    logger:info("Started repo with bucket ~p, options: ~p~n", [Bucket, Options]),
    case lists:keyfind(name, 1, Options) of
        {name, Name} -> true = register(Name, self());
        false -> false
    end,
    {ok, Conn} = riakc_pb_socket:start("127.0.0.1", 8087),
    {ok, {Conn, Bucket}}.

handle_call({store, Key, Value}, _From, {Riak, Bucket} = State) ->
    case riakc_obj:new(Bucket, term_to_binary(Key), Value) of
        {error, Error} ->
            {reply, Error, State};
        Object ->
            riakc_pb_socket:put(Riak, Object),
            {reply, ok, State}
    end;
handle_call({retrieve, Key}, _From, {Pid, MyBucket} = State) ->
    Result =
        case riakc_pb_socket:get(Pid, MyBucket, term_to_binary(Key)) of
            {ok, Fetched} ->
                Value = riakc_obj:get_value(Fetched),
                {ok, Value};
            {error, notfound} ->
                {error, notfound}
        end,
    {reply, Result, State}.

handle_cast(_Request, _State) ->
    erlang:error(not_implemented).
