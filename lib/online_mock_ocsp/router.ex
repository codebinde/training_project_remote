defmodule OnlineMockOCSP.Router do
  @moduledoc false

  use OnlineMockOCSP, :router

  pipeline :ocsp do
    # MIME type `application/ocsp-response` has file ending `ors`
    plug :accepts, ["ors"]
  end

  scope "/", OnlineMockOCSP do
    pipe_through :ocsp

    post "/", RequestController, :create
    get "/:ocsp_request", RequestController, :show

    post "/:issuer/", RequestController, :create
    get "/:issuer/:ocsp_request", RequestController, :show
  end
end
