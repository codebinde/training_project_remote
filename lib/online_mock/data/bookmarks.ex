defmodule OnlineMock.Data.Bookmarks do
  @moduledoc false

  import OnlineMock.Data, only: [into_creator_tuple: 1]

  def create(bookmarks) do
    OnlineMock.Data.create(
      bookmarks,
      &get_path/1,
      &do_create/1,
      &get_table/0
    )
  end

  def append(recipe_id, recipe_title, locale) do
    OnlineMock.Data.update(
      get_path(),
      &do_append(&1, recipe_id, recipe_title, locale),
      &get_table/0
    )
  end

  def remove(recipe_id) do
    OnlineMock.Data.update(
      get_path(),
      &do_remove(&1, recipe_id),
      &get_table/0
    )
  end

  def get_path(_ \\ nil) do
    "bookmarks"
  end

  def get_table() do
    :files_table
  end

  defp do_create(bookmarks) do
    bookmarks
    |> create_bookmarks_list()
    |> into_creator_tuple()
  end

  defp do_append(bookmarks_list, recipe_id, recipe_title, locale) do
    appendix = [create_bookmark(recipe_id, recipe_title, locale)]

    case bookmarks_list do
      bookmarks_list when is_list(bookmarks_list) ->
        bookmarks_list ++ appendix

      nil ->
        appendix
    end
    |> into_creator_tuple()
  end

  defp do_remove(bookmarks_list, recipe_id) do
    bookmarks_list
    |> Enum.reject(fn %{"recipe" => %{"id" => id}} -> id == recipe_id end)
    |> into_creator_tuple()
  end

  defp create_bookmarks_list(bookmarks) do
    for [recipe_id, recipe_title, locale] <- bookmarks do
      create_bookmark(recipe_id, recipe_title, locale)
    end
  end

  defp create_bookmark(recipe_id, recipe_title, locale) do
    image_path =
      to_string(%URI{
        scheme: "https",
        host: "assets.tmecosys.com",
        path: "/images/{transformation}/generic_image"
      })

    %{
      "id" => "Bookmarklist",
      "created" => DateTime.to_iso8601(DateTime.utc_now()),
      "recipe" => %{
        "id" => recipe_id,
        "title" => recipe_title,
        "asciiTitle" => recipe_title,
        "locale" => locale,
        "landscapeImage" => image_path,
        "prepTime" => "600.0",
        "assets" => %{
          "images" => %{
            "square" => image_path
          }
        }
      }
    }
  end
end
