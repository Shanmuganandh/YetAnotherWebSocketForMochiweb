%% @author Shan <shan.anand@gmail.com>
%% @copyright 2009 Shanmuganandh.

%% @doc Web server for wstest.

-module(wstest_web).
-author('Shan <shan.anand@gmail.com>').

-export([start/1, stop/0, loop/2, ws_loop/2]).

%% External API

start(Options) ->
    {DocRoot, Options1} = get_option(docroot, Options),
    Loop = fun (Req) ->
                   ?MODULE:loop(Req, DocRoot)
           end,
    mochiweb_http:start([{name, ?MODULE}, {loop, Loop} | Options1]).

stop() ->
    mochiweb_http:stop(?MODULE).

loop(Req, DocRoot) ->
    "/" ++ Path = Req:get(path),
    IsUpgrade = Req:get_header_value("Upgrade"),
    case IsUpgrade of 
	"WebSocket" ->
	    Origin = Req:get_header_value("Origin"),
	    ResourceLocation = mochiweb_util:urlunsplit({"ws", "localhost:8000", Req:get(path), "", ""}), 
	    Req:start_websocket({101,
				[{"WebSocket-Origin", Origin},
				 {"WebSocket-Location", ResourceLocation}]}),
	    mochiweb_ws:websocket_handler(Req, ?MODULE, ws_loop);
	undefined ->
	    case Req:get(method) of
		Method when Method =:= 'GET'; Method =:= 'HEAD' ->
		    case Path of
			_ ->
			    Req:serve_file(Path, DocRoot)
		    end;
		'POST' ->
		    case Path of
			_ ->
			    Req:not_found()
		    end;
		_ ->
		    Req:respond({501, [], []})
	    end
    end.


ws_loop(Parent, ResponseQueue) ->
    receive
	{received, DataFrame} ->
	    ws_loop(Parent, [DataFrame | ResponseQueue]);
	{send, DataFrame} ->
	    ws_loop(Parent, [DataFrame | ResponseQueue]);
	check_any_response ->
	    case length(ResponseQueue) of
		0 ->
		    Parent ! empty;
		_ ->
		    [Parent ! {send, X} || X <- lists:reverse(ResponseQueue) ]
	    end,
	    ws_loop(Parent, [])
    end.


%% Internal API

get_option(Option, Options) ->
    {proplists:get_value(Option, Options), proplists:delete(Option, Options)}.
