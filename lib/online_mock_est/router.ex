defmodule OnlineMockEST.Router do
  @moduledoc false

  use OnlineMockEST, :router

  scope "/.well-known/est", OnlineMockEST do
    get "/cacerts", CACertsController, :show
    post "/simpleenroll", SimpleenrollController, :create
    post "/simplereenroll", SimpleenrollController, :create, as: :simplereenroll
  end
end
