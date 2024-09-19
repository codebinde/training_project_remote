defmodule OnlineMockCookidoo.Search.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "search:home-with-filters-exploded": %{href: url(~p"/search/home-with-filters-exploded")},
        "search:search-config": %{href: url(~p"/search/search-config")}
      }
    })
  end
end
