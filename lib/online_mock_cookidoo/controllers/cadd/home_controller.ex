defmodule OnlineMockCookidoo.CADD.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "cadd:update": %{
          href:
            url(~p"/cadd/update/minFirmware")
            |> String.replace("minFirmware", "{minFirmware}"),
          templated: true
        }
      }
    })
  end
end
