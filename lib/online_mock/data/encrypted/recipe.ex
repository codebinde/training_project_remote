defmodule OnlineMock.Data.Encrypted.Recipe do
  @moduledoc false

  import OnlineMock.Data.Encrypted, only: [encrypted: 1]

  def create(recipe, format \\ :yaml) do
    OnlineMock.Data.create(
      recipe,
      &path_for_recipe(&1, format),
      &do_create(&1, format),
      &get_table/0
    )
  end

  def path_for_id(id) do
    Path.join("/recipes", "#{id}.enc")
  end

  def get_table() do
    :files_table
  end

  defp path_for_recipe(%{"Id" => id}, :yaml) do
    path_for_id(id)
  end

  defp path_for_recipe(recipe, :json) do
    %{"Id" => id} = Jason.decode!(recipe)
    path_for_id(id)
  end

  defp do_create(recipe, :yaml) do
    recipe
    |> Jason.encode!()
    |> compress_and_encrypt()
  end

  defp do_create(recipe, :json) do
    compress_and_encrypt(recipe)
  end

  defp compress_and_encrypt(recipe) do
    recipe
    |> :zlib.gzip()
    |> encrypted()
  end
end
