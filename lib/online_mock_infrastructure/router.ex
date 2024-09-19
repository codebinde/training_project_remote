defmodule OnlineMockInfrastructure.Router do
  @moduledoc false

  use OnlineMockInfrastructure, :router

  pipeline :home_document do
    plug :accepts, ["hal"]
  end

  scope "/.well-known/device-infrastructure-home", OnlineMockInfrastructure do
    pipe_through :home_document

    get "/:country", HomeController, :show
  end

  get "/time", OnlineMockInfrastructure.TimeController, :show
end
