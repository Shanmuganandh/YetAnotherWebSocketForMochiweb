-module(mochiweb_ws).

-export([websocket_handler/3]).


websocket_handler(Req, Module, WsLoop) ->
    WsLoopPid = spawn(Module, WsLoop, [self(), []]),
    websocket_receiver(Req, WsLoopPid, []).


websocket_receiver(Req, LoopId, Buffer) ->
    LoopId ! check_any_response,
    receive
	{send, Data} ->
	    Req:send(list_to_binary(lists:flatten([$\x{00}, Data, $\x{FF}])));
	empty ->
	    ok
    end,
    Byte = Req:ws_recv(),
    case Byte of 
	<<$\x{00}>> ->
	    websocket_receiver(Req, LoopId, []);
	<<$\x{FF}>> ->
	    DataFrame = list_to_binary(lists:reverse(Buffer)),
	    LoopId ! {received, DataFrame},
	    websocket_receiver(Req, LoopId, []);
	empty ->
	    websocket_receiver(Req, LoopId, Buffer);
	_ ->
	    websocket_receiver(Req, LoopId, [Byte | Buffer])
    end.

