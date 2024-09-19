defmodule OnlineMock.Data.OwnershipList do
  @moduledoc false

  import OnlineMock.Data, only: [into_creator_tuple: 1]

  def create(ownership_list) do
    OnlineMock.Data.create(
      ownership_list,
      &get_path/1,
      &do_create/1,
      &get_table/0
    )
  end

  def append(recipe_id, type, retention_priority \\ nil) do
    OnlineMock.Data.update(
      get_path(),
      &do_append(&1, recipe_id, type, retention_priority),
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

  def get() do
    OnlineMock.Data.lookup_data(&get_table/0, get_path(), [])
  end

  def get_path(_ \\ nil) do
    "ownership-list"
  end

  def get_table() do
    :files_table
  end

  defp do_create(ownership_list) do
    ownership_list
    |> create_ownership_list()
    |> into_creator_tuple()
  end

  defp do_append(ownership_list, recipe_id, type, retention_priority) do
    appendix = [create_entry(recipe_id, type, retention_priority)]

    case ownership_list do
      ownership_list when is_list(ownership_list) ->
        ownership_list ++ appendix

      nil ->
        appendix
    end
    |> into_creator_tuple()
  end

  defp do_remove(ownership_list, recipe_id) do
    ownership_list
    |> Enum.reject(fn %{"id" => id} -> id == recipe_id end)
    |> into_creator_tuple()
  end

  defp create_ownership_list(ownership_list) do
    for [recipe_id, type, retention_priority] <- ownership_list do
      create_entry(recipe_id, type, retention_priority)
    end
  end

  defp create_entry(recipe_id, type, retention_priority) do
    %{
      "id" => recipe_id,
      "type" => type
    }
    |> maybe_merge_retention_priority(retention_priority)
  end

  defp maybe_merge_retention_priority(entry, nil = _retention_priority) do
    entry
  end

  defp maybe_merge_retention_priority(entry, retention_priority) do
    Map.merge(entry, %{"retention_priority" => retention_priority})
  end
end
