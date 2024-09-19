defmodule OnlineMockCookidoo.Planning.MyWeekJSON do
  @moduledoc false

  alias OnlineMock.Data.PlannedRecipes

  def show(%{id: id}) do
    %{
      "author" => "CI MOCK SERVER",
      "myDays" =>
        for [day, recipes] <- PlannedRecipes.get_recipes_after(id) do
          %{
            "author" => "VORWERK",
            "date" => day,
            "dayKey" => day,
            "id" => day,
            "recipeCount" => 1,
            "totalRecipeCount" => 1,
            "recipeIds" => Enum.map(recipes, &Map.get(&1, "id")),
            "customerRecipeIds" => [],
            "recipes" => recipes,
            "title" => "my-day recipe #{day}",
            "userId" => "",
            "version" => 1
          }
        end,
      "userId" => "",
      "recipeCount" => 0
    }
  end
end
