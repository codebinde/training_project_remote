defmodule OnlineMockCookidoo.Planning.MoveRecipeJSON do
  @moduledoc false

  def create(%{
        day_key: day_key,
        old_day_key: old_day_key,
        recipe_id: recipe_id,
        recipe_source: recipe_source
      }) do
    %{
      "content" => %{
        "dayKey" => day_key,
        "oldDayKey" => old_day_key,
        "recipeId" => recipe_id,
        "recipeSource" => recipe_source
      },
      "message" => "create response"
    }
  end
end
