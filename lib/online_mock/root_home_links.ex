defmodule OnlineMock.RootHomeLinks do
  @moduledoc false

  @state_path [&__MODULE__.access_state/3]

  def list_removed_links do
    OnlineMock.State.get(@state_path) |> MapSet.to_list()
  end

  def remove_link(relations) when is_list(relations) do
    for rel <- relations, do: remove_link(rel)
  end

  def remove_link(relation) when is_binary(relation) do
    relation = String.to_existing_atom(relation)
    OnlineMock.State.update(@state_path, fn relations -> MapSet.put(relations, relation) end)
  end

  def reset_links do
    OnlineMock.State.pop(@state_path)
  end

  # must be public in order to capture it via remote call
  def access_state(operation, data, fun) do
    Access.key(__MODULE__, MapSet.new()).(operation, data, fun)
  end
end
