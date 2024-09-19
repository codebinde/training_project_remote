defmodule OnlineMockCookidoo.RecipeAssets.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "sa:modes": %{href: url(~p"/recipe-assets/modes.tar.gz")},
        "sa:icons": %{href: url(~p"/recipe-assets/icons.tar.gz")},
        "sa:primary-categories": %{href: url(~p"/recipe-assets/primary-categories.tar.gz")},
        "rd:recipe": %{
          href:
            url(~p"/recipe-assets/recipes/recipe_id")
            |> String.replace("recipe_id", "{recipe_id}"),
          templated: true
        },
        "rd:vorwerk-recipe": %{
          href:
            url(~p"/recipe-assets/recipes/recipe_id")
            |> String.replace("recipe_id", "{recipe_id}"),
          templated: true
        },
        "rd:macro": %{
          href:
            url(~p"/recipe-assets/macros/macro_id") |> String.replace("macro_id", "{macro_id}"),
          templated: true
        }
      }
    })
  end
end
