defmodule OnlineMockCookidoo.Auth.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "auth:resource-owner-password-flow": %{href: url(~p"/auth/token")},
        "auth:open-id-connect-discovery": %{
          href: url(~p"/auth/.well-known/openid-configuration")
        }
      }
    })
  end
end
