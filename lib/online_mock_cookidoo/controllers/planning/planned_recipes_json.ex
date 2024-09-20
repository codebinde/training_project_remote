defmodule OnlineMockCookidoo.Planning.PlannedRecipesJSON do
  alias OnlineMock.Data.PlannedRecipes
  import OnlineMockCookidoo.Planning.Common

  def index(%{my_day_id: my_day_id}) do
    recipe_ids =
      for recipe <- PlannedRecipes.get_recipes_for_day(my_day_id), do: recipe["id"]

    %{"dayKeys" => recipe_ids}
  end

  def delete(%{my_day_id: my_day_id, id: id}) do
    %{
      "message" => "delete response for deleting #{id} for my day #{my_day_id}",
      "content" => my_day_dto(my_day_id)
    }
  end
end
