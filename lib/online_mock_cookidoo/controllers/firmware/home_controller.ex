defmodule OnlineMockCookidoo.Firmware.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "firmware:update": %{href: url(~p"/firmware/update?version={version}"), templated: true},
        "firmware:tmd": %{
          href:
            url(
              ~p"/firmware/tmd?firmwareVersion={firmwareVersion}&hardwareVersion={hardwareVersion}&id={id}"
            ),
          templated: true
        }
      }
    })
  end
end
