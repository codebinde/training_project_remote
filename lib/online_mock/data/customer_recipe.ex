defmodule OnlineMock.Data.CustomerRecipe do
  @moduledoc false

  import OnlineMock.Data, only: [into_creator_tuple: 1]

  def create(recipe) do
    OnlineMock.Data.create(
      recipe,
      &path_for_recipe/1,
      &do_create/1,
      &get_table/0
    )
  end

  def path_for_id(id) do
    Path.join("/customer-recipes", "#{id}")
  end

  def get(id) do
    OnlineMock.Data.lookup_data(&get_table/0, path_for_id(id))
  end

  def get_table() do
    :files_table
  end

  defp path_for_recipe(recipe) do
    %{"Id" => id} = Jason.decode!(recipe)
    path_for_id(id)
  end

  defp do_create(recipe) do
    recipe
    |> into_creator_tuple()
  end
end
