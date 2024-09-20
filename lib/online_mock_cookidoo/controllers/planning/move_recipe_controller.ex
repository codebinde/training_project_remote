defmodule OnlineMockCookidoo.Planning.MoveRecipeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMock.Data.PlannedRecipes

  @allowed_sources ~w(VORWERK CUSTOMER)

  def create(conn, %{
        "dayKey" => day_key,
        "oldDayKey" => old_day_key,
        "recipeId" => recipe_id,
        "recipeSource" => recipe_source
      })
      when recipe_source in @allowed_sources do
    PlannedRecipes.move(recipe_id, old_day_key, day_key)

    render(conn, :create,
      day_key: day_key,
      old_day_key: old_day_key,
      recipe_id: recipe_id,
      recipe_source: recipe_source
    )
  end
end
