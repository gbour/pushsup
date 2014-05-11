
%
-module(api_rest).
-author("Guillaume Bour <guillaume@bour.cc>").

-export([init/3, handle/2, terminate/3]).

init(_Transport, Req, []) ->
    {ok, Req, undefined}.

handle(Req, State) ->
    {Method, Req2} = cowboy_req:method(Req),
    {Path  , Req3} = cowboy_req:path(Req2),

    {ok, Req4} = do(Method, Path, Req3),
    {ok, Req4, State}.

do(<<"GET">>, <<"/register">>, Req) ->
    {UserId, _Req2} = cowboy_req:qs_val(<<"userid">>, Req),
    {PushId, _Req3} = cowboy_req:header(<<"pushid">>, Req),

    io:format("registering *~p* user (deviceid= ~p)~n", [UserId, PushId]),
    Reply = try ets:insert(devices, {UserId, PushId}) of
        _ ->
            cowboy_req:reply(200, [], "", Req)
    catch
        _ ->
            cowboy_req:reply(503, [], "", Req)
    end,

    Reply;

do(<<"GET">>, <<"/push">>, Req) ->
    {UserId, _Req2} = cowboy_req:qs_val(<<"userid">>, Req),
    {Event , _Req3} = cowboy_req:qs_val(<<"event">> , Req),

    % get pushid from userid
    Reply = case ets:lookup(devices, UserId) of
        [{UserId, PushId}] ->
            service_gcm:send(Event, PushId),
            cowboy_req:reply(200, [], "", Req);

        _ ->
            io:format("user ~p is not registered~n", [UserId]),
            cowboy_req:reply(404, [], "", Req)
    end,

    Reply;

do(_, Query, Req) ->
    io:format("invalid ~p query~n", [Query]),
    cowboy_req:reply(405, Req).

terminate(_Reason, _Req, _State) ->
    ok.
