%% @author author <author@example.com>
%% @copyright YYYY author.

%% @doc Callbacks for the wstest application.

-module(wstest_app).
-author('author <author@example.com>').

-behaviour(application).
-export([start/2,stop/1]).


%% @spec start(_Type, _StartArgs) -> ServerRet
%% @doc application start callback for wstest.
start(_Type, _StartArgs) ->
    wstest_deps:ensure(),
    wstest_sup:start_link().

%% @spec stop(_State) -> ServerRet
%% @doc application stop callback for wstest.
stop(_State) ->
    ok.
