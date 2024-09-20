defmodule OnlineMock.Data do
  @moduledoc false

  @default_etag Base.encode64(<<1>>)

  def create(data, path_for_data, creator, table) do
    {created_data, extra_tags} = data |> creator.()

    data
    |> path_for_data.()
    |> insert_into_files_table(created_data, extra_tags, table.())
  end

  def update(path, updater, table) do
    old_data = lookup_data(table, path)
    {new_data, extra_tags} = old_data |> updater.()
    insert_into_files_table(path, new_data, extra_tags, table.())
  end

  def lookup_data(table, path, default \\ nil) do
    if :ets.member(table.(), path) do
      %{data: data} = :ets.lookup_element(table.(), path, 2)
      data
    else
      default
    end
  end

  def insert_into_files_table(path, data, extra_tags, table) do
    entry =
      %{
        data: data,
        etag: OnlineMock.Data.Etag.create_etag(data, %{use_time: true})
      }
      |> Map.merge(extra_tags)

    :ets.insert(table, {path, entry})
    data
  end

  def etag_for_connection(%{params: %{"id" => id}}, path, table) do
    retrieve_etag(path.(id), table.())
  end

  def etag_for_connection(_conn, path, table) do
    retrieve_etag(path.(), table.())
  end

  def into_creator_tuple(data, extra_tags \\ %{}) do
    {data, extra_tags}
  end

  def retrieve_etag(path, table) do
    if :ets.member(table, path) do
      %{etag: etag} = :ets.lookup_element(table, path, 2)
      etag
    else
      @default_etag
    end
  end
end
