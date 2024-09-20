defmodule OnlineMockCookidoo.RecipeDetails.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "recipe-variants": %{
          href:
            url(~p"/recipe-details/cluster/clusterId")
            |> String.replace("clusterId", "{clusterId}"),
          templated: true
        }
      }
    })
  end
end
