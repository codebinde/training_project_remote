defmodule OnlineMockCookidoo.CustomerRecipes.RecipesListController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, _params) do
    stored_recipes = OnlineMock.State.get([:customer_recipes], %{})
    recipes = Map.keys(stored_recipes)

    render(conn, :index, recipes: recipes)
  end

  def show(conn, %{"recipe" => recipe}) do
    stored_recipes = OnlineMock.State.get([:customer_recipes])

    case Map.get(stored_recipes, recipe) do
      recipe_steps when is_list(recipe_steps) ->
        body_attributes = [onload: "COOKIDOO.device.preloadScaleDialog()"]
        render(conn, :show, recipe: recipe, body_attributes: body_attributes)

      nil ->
        send_resp(conn, :not_found, "Not Found")
    end
  end
end
