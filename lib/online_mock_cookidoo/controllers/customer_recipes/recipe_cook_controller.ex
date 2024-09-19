defmodule OnlineMockCookidoo.CustomerRecipes.RecipeCookController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, %{"recipe" => recipe}) do
    stored_recipes = OnlineMock.State.get([:customer_recipes])
    recipe_steps = stored_recipes[recipe]

    render(conn, :show, recipe: recipe, recipe_steps: recipe_steps)
  end
end
