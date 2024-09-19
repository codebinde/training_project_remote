defmodule OnlineMockCookidoo.CustomerRecipes.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "customer-recipes:recipes-list": %{href: url(~p"/customer-recipes/recipes-list")},
        "customer-recipes:device-offline-recipes": %{
          href: url(~p"/customer-recipes/device-offline-recipes")
        },
        "customer-recipes:device-recipe-details": %{
          href:
            url(~p"/customer-recipes/recipe-details/recipe_id")
            |> String.replace("recipe_id", "{recipe_id}"),
          templated: true
        }
      }
    })
  end
end
