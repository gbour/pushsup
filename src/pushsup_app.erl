-module(pushsup_app).

-behaviour(application).

%% Application callbacks
-export([start/0, start/2, stop/1]).

%% ===================================================================
%% Application callbacks
%% ===================================================================

start() ->
    % HTTP client
    application:start(crypto),
    application:start(asn1),
    application:start(public_key),
    application:start(ssl),


    % HTTP server (Push API)
    application:start(ranch),
    application:start(cowlib),
    application:start(cowboy),

	application:start(pushsup).


start(_StartType, _StartArgs) ->
    io:format("starting pushup server...~n", []),

    ibrowse:start(),

    % create devices database
    ets:new(devices, [set,public,named_table]),

    % cowboy - start listener
    Dispatch = cowboy_router:compile([
        {'_', [{'_', api_rest, []}]}
    ]),

    {ok, _} = cowboy:start_http(http, 100,
        [{port, 8080}],
        [{env, [{dispatch, Dispatch}]}]
    ),

    % start supervisor
    pushsup_sup:start_link().

stop(_State) ->
    ibrowse:stop(),
    ets:delete(devices),

    ok.
