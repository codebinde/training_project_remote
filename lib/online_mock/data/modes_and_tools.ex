defmodule OnlineMock.Data.ModesAndTools do
  @moduledoc false

  import OnlineMock.Data, only: [into_creator_tuple: 2]

  @modes_archive "modes.tar.gz"
  @modes_filename "modes_tools_collection.json"

  def create(modes_and_tools, schema_version) do
    OnlineMock.Data.create(
      modes_and_tools,
      &get_path/1,
      &do_create(&1, schema_version),
      &get_table/0
    )
  end

  def get_path(_ \\ nil) do
    @modes_archive
  end

  def get_table() do
    :files_table
  end

  defp do_create(modes_and_tools, schema_version) do
    modes_and_tools
    |> create_modes_and_tools_list()
    |> create_modes_and_tools_collection(schema_version)
    |> Jason.encode!(pretty: true)
    |> create_modes_and_tools_archive()
    |> into_creator_tuple(%{filename: @modes_filename})
  end

  defp create_modes_and_tools_list(modes_and_tools) do
    for [type, macro_id, id] <- modes_and_tools do
      create_mode_or_tool(type, macro_id, id)
    end
  end

  defp create_mode_or_tool(type, macro_id, id) do
    %{
      "Type" => type,
      "MacroId" => macro_id,
      "Id" => id
    }
  end

  defp create_modes_and_tools_collection(modes_and_tools, schema_version) do
    %{
      "SchemaVersion" => schema_version,
      "Id" => "MTC",
      "ModesToolsCollection" => modes_and_tools
    }
  end

  defp create_modes_and_tools_archive(collection) do
    OnlineMock.RamArchive.create(%{data: collection, name: @modes_filename})
  end
end
