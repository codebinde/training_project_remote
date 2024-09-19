defmodule OnlineMockRobotRemote.Router do
  @moduledoc false

  use OnlineMockRobotRemote, :router

  pipeline :rpc do
    plug :accepts, ["xml"]
  end

  scope "/RPC2", OnlineMockRobotRemote do
    pipe_through :rpc

    post "/", RPCController, :create, log: false
  end
end
