defmodule OnlineMock.Data.PlannedRecipes do
  @moduledoc false

  import OnlineMock.Data, only: [into_creator_tuple: 1]

  @generic_image_url "https://assets.tmecosys.com/images/{transformation}/generic_image"
  @path "planned_recipe"

  def create(planned_recipes_for_day) do
    OnlineMock.Data.create(
      planned_recipes_for_day,
      &get_path_for_data/1,
      &do_create/1,
      &get_table/0
    )
  end

  def append(day_id, recipe_id, locale) do
    OnlineMock.Data.update(
      get_path_for_id(day_id),
      &do_append(&1, recipe_id, locale),
      &get_table/0
    )
  end

  def remove(day_id, recipe_id) do
    OnlineMock.Data.update(
      get_path_for_id(day_id),
      &do_remove(&1, recipe_id),
      &get_table/0
    )
  end

  def move(recipe_id, from_day_id, to_day_id) do
    get_recipes_for_day(from_day_id)
    |> Enum.filter(fn %{"id" => id} -> id == recipe_id end)
    |> Enum.each(fn recipe -> do_move(recipe, from_day_id, to_day_id) end)
  end

  def remove_all(day_id) do
    :ets.delete(get_table(), get_path_for_id(day_id))
  end

  def get_recipes_for_day(day_id) do
    OnlineMock.Data.lookup_data(
      &get_table/0,
      get_path_for_id(day_id),
      []
    )
  end

  def recipes_planned_for_day?(day_id) do
    :ets.member(get_table(), get_path_for_id(day_id))
  end

  def get_recipes_after(day_id) do
    match_planned_recipes_after(day_id, :data)
  end

  def get_etags_for_recipes_after(day_id) do
    match_planned_recipes_after(day_id, :etag)
  end

  defp match_planned_recipes_after(day_id, tag) do
    get_table()
    |> :ets.match({{@path, :"$1"}, %{tag => :"$2"}})
    |> Enum.filter(fn [date | _] -> date >= day_id end)
  end

  def get_path_for_data({day_id, _}) do
    get_path_for_id(day_id)
  end

  def get_path_for_id(day_id) do
    {@path, day_id}
  end

  def get_table() do
    :files_table
  end

  defp do_create({_, planned_recipes}) do
    planned_recipes
    |> create_planned_recipes_list()
    |> into_creator_tuple()
  end

  defp do_append(planned_recipes, recipe_id, locale) do
    appendix = [recipe_entry(recipe_id, locale)]

    case planned_recipes do
      planned_recipes when is_list(planned_recipes) ->
        planned_recipes ++ appendix

      nil ->
        appendix
    end
    |> into_creator_tuple()
  end

  defp do_remove(planned_recipes, recipe_id) do
    planned_recipes
    |> Enum.reject(fn %{"id" => id} -> id == recipe_id end)
    |> into_creator_tuple()
  end

  defp create_planned_recipes_list(planned_recipes) do
    for [recipe_id, locale] <- planned_recipes do
      recipe_entry(recipe_id, locale)
    end
  end

  defp do_move(%{"id" => id, "locale" => locale}, from_day_id, to_day_id) do
    remove(from_day_id, id)
    append(to_day_id, id, locale)
  end

  defp generic_assets() do
    %{
      "images" => %{
        "landscape" => @generic_image_url,
        "portrait" => @generic_image_url,
        "square" => @generic_image_url
      }
    }
  end

  def recipe_entry(recipe_id, locale) do
    %{
      "asciiTitle" => recipe_id,
      "assets" => generic_assets(),
      "id" => recipe_id,
      "locale" => locale,
      "title" => recipe_id,
      "landscapeImage" => @generic_image_url
    }
  end
end
