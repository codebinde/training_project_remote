defmodule OnlineMockCookidoo.StolenDevices.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "stolen-devices:status": %{href: url(~p"/stolen-devices/status")}
      }
    })
  end
end
