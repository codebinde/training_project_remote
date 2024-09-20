defmodule OnlineMockCookidoo.Ownership.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "ownership:collections": %{href: url(~p"/ownership/collections")},
        "ownership:subscriptions": %{href: url(~p"/ownership/subscriptions")},
        "ownership:recipes": %{href: url(~p"/ownership/recipes")},
        "recipe-sync:device-offline-recipes": %{href: url(~p"/ownership/offline-recipes")}
      }
    })
  end
end
