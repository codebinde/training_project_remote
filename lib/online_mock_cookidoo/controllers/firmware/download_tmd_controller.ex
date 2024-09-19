defmodule OnlineMockCookidoo.Firmware.DownloadTMDController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  require Logger

  plug :find_download
  plug Plug.CacheControl, etag_generation: {__MODULE__, :md5, []}

  @total_chunk_count 100

  def show(conn, _params) do
    OnlineMock.LockHandle.await_unlock(:firmware_download)

    {firmware_file_chunks, size} =
      conn.assigns.path
      |> File.read!()
      |> chunk_stream()

    conn
    |> initialize_chunked_response(size, Path.basename(conn.assigns.path))
    |> send_chunks(firmware_file_chunks)
  end

  def find_download(conn, _opts) do
    with %{"name" => name} <- conn.params,
         {_version, path} <- OnlineMock.State.get([:firmware_tmd]),
         ^name <- path |> Path.basename() |> Path.rootname() do
      assign(conn, :path, path)
    else
      _ ->
        conn
        |> send_resp(:not_found, "")
        |> halt()
    end
  end

  def md5(conn) do
    conn.assigns.path
    |> File.read!()
    |> :erlang.md5()
    |> Base.encode16()
  end

  defp initialize_chunked_response(conn, content_length, filename) do
    conn
    |> put_resp_header("content-length", "#{content_length}")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{filename}\"")
    |> send_chunked(:ok)
  end

  defp send_chunks(conn, chunks) do
    chunk_count = Enum.count(chunks)

    chunks
    |> Enum.with_index(fn chunk, i -> {chunk_count, i, chunk} end)
    |> Enum.reduce_while(conn, &handle_chunk/2)
  end

  defp handle_chunk({chunk_count, i, chunk}, conn) do
    check_lock_loop(chunk_count, i)

    case chunk(conn, chunk) do
      {:ok, conn} ->
        {:cont, conn}

      _ ->
        {:halt, conn}
    end
  end

  defp check_lock_loop(chunk_count, i) do
    case OnlineMock.State.get([:firmware_tmd_lock_percentage]) do
      p when is_integer(p) and p >= 0 and p <= 100 ->
        if trunc(i / chunk_count * 100) >= p do
          OnlineMock.LockHandle.await_unlock(:firmware_percentage_lock)
          check_lock_loop(chunk_count, i)
        end

      _ ->
        :ok
    end
  end

  defp chunk_stream(binary) do
    byte_size = byte_size(binary)
    # split into roughly 100 chunks
    size = max(1, trunc(byte_size / @total_chunk_count))

    stream =
      Stream.resource(
        fn -> binary end,
        fn
          :halt ->
            {:halt, nil}

          <<head::binary-size(size), tail::binary>> ->
            {[head], tail}

          tail ->
            {[tail], :halt}
        end,
        fn _ -> nil end
      )

    {stream, byte_size}
  end
end
