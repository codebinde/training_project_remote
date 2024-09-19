defmodule OnlineMockCookidoo.Usagebox.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "usagebox:device-config": %{href: url(~p"/usagebox/device-config")},
        "usagebox:upload-url": %{href: url(~p"/usagebox/upload-url")}
      }
    })
  end
end
