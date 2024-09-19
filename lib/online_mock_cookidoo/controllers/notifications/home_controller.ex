defmodule OnlineMockCookidoo.Notifications.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "notifications:collection": %{
          href: url(~p"/notifications/lang") |> String.replace("lang", "{lang}"),
          templated: true
        }
      }
    })
  end
end
