defmodule OnlineMock.RamArchive do
  @moduledoc """
  Module to create tar archives in RAM.
  """

  @doc """
  Creates a 'tar' archive.

  ## Options

  The supported options are:

    * `:compressed` - The archive is compressed in case this is `true` (which is the default).
  """
  def create(files_or_data, opts \\ [])

  def create(%{} = files_or_data, opts) do
    create([files_or_data], opts)
  end

  def create(files_or_data, opts) when is_list(files_or_data) do
    files_or_data
    |> create_from_list()
    |> dump(opts)
  end

  defp create_from_list(list_of_files_or_data) do
    tar_desc = create_and_open_tar_desc()

    for file_or_data <- list_of_files_or_data do
      create_one(tar_desc, file_or_data)
    end

    tar_desc
  end

  defp create_one(tar_desc, %{path: path, name: name}) do
    add_to_tar(tar_desc, to_charlist(path), to_charlist(name))
  end

  defp create_one(tar_desc, %{data: data, name: name}) do
    add_to_tar(tar_desc, data, to_charlist(name))
  end

  defp add_to_tar(tar_desc, file_or_data, name) do
    :ok = :erl_tar.add(tar_desc, file_or_data, name, [])
  end

  defp create_and_open_tar_desc do
    {:ok, fd} = :ram_file.open("", [:write, :read])

    {:ok, tar_desc} =
      :erl_tar.init(fd, :write, fn
        :write, {fd, data} -> :ram_file.write(fd, data)
        :position, {fd, pos} -> :ram_file.position(fd, pos)
        :read2, {fd, size} -> :ram_file.read(fd, size)
        :close, fd -> :ram_file.close(fd)
      end)

    tar_desc
  end

  defp dump({_, fd, _, _, _} = tar_desc, opts) do
    {:ok, size} = :ram_file.get_size(fd)
    {:ok, data} = :ram_file.pread(fd, 0, size)
    :erl_tar.close(tar_desc)

    if Keyword.get(opts, :compressed, true) do
      :zlib.gzip(data)
    else
      data
    end
  end
end
