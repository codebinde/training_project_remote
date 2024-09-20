defmodule OnlineMockCookidoo.Planning.Common do
  @moduledoc false

  alias OnlineMock.Data.PlannedRecipes

  def my_day_dto(day_id) do
    planned_recipes = PlannedRecipes.get_recipes_for_day(day_id)

    recipe_ids =
      for recipe <- planned_recipes, do: recipe["id"]

    %{
      "author" => "VORWERK",
      "date" => day_id,
      "dayKey" => day_id,
      "id" => day_id,
      "recipeCount" => 1,
      "totalRecipeCount" => 1,
      "recipeIds" => recipe_ids,
      "customerRecipeIds" => [],
      "recipes" => planned_recipes,
      "title" => "my-day recipes for #{day_id}",
      "userId" => "",
      "version" => 1
    }
  end

  def default_day_id() do
    OnlineMock.DateTime.utc_now()
    |> format_to_day_id()
  end

  defp format_to_day_id(datetime) do
    year = "#{datetime.year}"
    month = "#{datetime.month}" |> String.pad_leading(2, "0")
    day = "#{datetime.day}" |> String.pad_leading(2, "0")
    "#{year}-#{month}-#{day}"
  end
end
