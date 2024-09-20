defmodule OnlineMock.Data.Encrypted.Macro do
  @moduledoc false

  import OnlineMock.Data.Encrypted, only: [encrypted: 1]

  def create(path) do
    OnlineMock.Data.create(path, &get_path/1, &do_create/1, &get_table/0)
  end

  def path_for_id(id) do
    Path.join("/macros", "#{id}.enc")
  end

  def get_table() do
    :files_table
  end

  defp get_path(path) do
    path |> Path.basename() |> path_for_id()
  end

  defp do_create(path) do
    OnlineMock.RamArchive.create(%{path: path, name: ""})
    |> encrypted()
  end
end
