
%
%
-module(service_gcm).
-author("Guillaume Bour <guillaume@bour.cc>").

-include_lib("erlson/include/erlson.hrl").

-define(SERVER_KEY, "XYZ").
-export([send/2]).


send(Event, PushId) ->
    Msg = #{
        registration_ids = [PushId],
        collapse_key = Event
    },

    JsonMsg = erlson:to_json(Msg),
    io:format("Message= ~p~n", [erlang:iolist_to_binary(JsonMsg)]),

    Resp = ibrowse:send_req("https://android.googleapis.com/gcm/send", 
        [
            {authorization, <<"key=", ?SERVER_KEY>>},
            {content_type, <<"application/json">>}
        ], 
        post,
        JsonMsg
    ),
    io:format("Resp= ~p~n", [Resp]),

    ok.
