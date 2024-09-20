defmodule OnlineMock.Keywords.Cookidoo.Organize do
  @moduledoc false

  use RemoteLibrary

  @doc """
  Removes a recipe from bookmarks
  """
  @keyword "Remove Recipe From Bookmarks"
  @keyword_doc @doc
  @spec remove_from_bookmarks(String.t()) :: :ok
  def remove_from_bookmarks(id) do
    OnlineMock.Data.Bookmarks.remove(id)

    :ok
  end

  @doc """
  Appends a recipe to bookmarks
  """
  @keyword "Append Recipe To Bookmarks"
  @keyword_doc @doc
  @keyword_args %{locale: {"en", nil}}
  @spec append_to_bookmarks(String.t(), String.t(), String.t()) :: :ok
  def append_to_bookmarks(recipe_id, recipe_title, locale) do
    OnlineMock.Data.Bookmarks.append(recipe_id, recipe_title, locale)

    :ok
  end
end
