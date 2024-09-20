defmodule OnlineMockCookidoo.CustomerDevices.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "customer-devices:api-activation-status": %{href: url(~p"/customer-devices/activation")},
        "customer-devices:api-activate": %{href: url(~p"/customer-devices/activation")},
        "customer-devices:api-deactivate": %{href: url(~p"/customer-devices/activation")}
      }
    })
  end
end
