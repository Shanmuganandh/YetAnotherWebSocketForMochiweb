%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc TEMPLATE.

-module(wstest).
-author('author <author@example.com>').
-export([start/0, stop/0]).

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.
        
%% @spec start() -> ok
%% @doc Start the wstest server.
start() ->
    wstest_deps:ensure(),
    ensure_started(crypto),
    application:start(wstest).

%% @spec stop() -> ok
%% @doc Stop the wstest server.
stop() ->
    Res = application:stop(wstest),
    application:stop(crypto),
    Res.
