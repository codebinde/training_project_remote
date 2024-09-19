defmodule OnlineMockCookidoo.Recommender.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "recommender:offlinerecipes": %{href: url(~p"/recommender/offline-recipes")}
      }
    })
  end
end
