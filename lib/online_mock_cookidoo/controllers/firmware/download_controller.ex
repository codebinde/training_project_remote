defmodule OnlineMockCookidoo.Firmware.DownloadController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  require Logger

  plug :find_file
  plug :chunked_download

  def show(conn, _params) do
    OnlineMock.log_event(:download_firmware, conn.assigns.file)
    send_download(conn)
  end

  defp send_download(%{assigns: %{chunked: false}} = conn) do
    send_download(conn, {:binary, conn.assigns.enc}, filename: conn.assigns.file)
  end

  defp send_download(%{assigns: %{chunked: true}} = conn) do
    conn
    |> put_resp_header("content-length", "#{byte_size(conn.assigns.enc)}")
    |> put_resp_header("content-disposition", "attachment; filename=\"#{conn.assigns.file}\"")
    |> send_chunked(:ok)
    |> send_chunks()
  end

  defp send_chunks(conn) do
    chunks = chunk_stream(conn.assigns.enc, conn.assigns.number)
    Enum.reduce_while(chunks, conn, &send_chunk/2)
  end

  defp send_chunk({number, chunk}, conn) do
    Process.sleep(conn.assigns.timeout)
    file = conn.assigns.file
    OnlineMock.LockHandle.await_unlock({:firmware_download_chunk, file, number})

    case chunk(conn, chunk) do
      {:ok, conn} ->
        Logger.debug("Sent chunk #{number} of file #{file} (#{byte_size(chunk)} bytes)")
        {:cont, conn}

      {:error, :closed} ->
        Logger.warning("Connection closed")
        {:halt, conn}
    end
  end

  defp chunk_stream(binary, number_of_chunks) do
    size = byte_size(binary)
    chunk_size = div(size, number_of_chunks)
    rem = rem(size, number_of_chunks)
    Stream.resource(fn -> {binary, chunk_size, rem, 1} end, &next_chunk/1, fn _ -> nil end)
  end

  defp next_chunk(:halt) do
    {:halt, nil}
  end

  defp next_chunk({binary, chunk_size, rem, number}) do
    {next_chunk_size, rem} = next_chunk_size(chunk_size, rem)

    case binary do
      <<head::binary-size(next_chunk_size)>> <> <<>> ->
        {[{number, head}], :halt}

      <<head::binary-size(next_chunk_size)>> <> tail ->
        {[{number, head}], {tail, chunk_size, rem, number + 1}}
    end
  end

  defp next_chunk_size(chunk_size, rem) when rem > 0, do: {chunk_size + 1, rem - 1}
  defp next_chunk_size(chunk_size, rem), do: {chunk_size, rem}

  defp find_file(%{params: %{"key" => key}} = conn, _opts) do
    case :ets.lookup(:fragments_table, key) do
      [{_, {file, enc}}] ->
        merge_assigns(conn, file: file, enc: enc)

      [] ->
        conn |> send_resp(:not_found, "Not Found") |> halt()
    end
  end

  defp chunked_download(conn, _opts) do
    behavior = OnlineMock.State.get([Access.key(:firmware_download_behavior, %{})])
    assign_chunked(conn, behavior, conn.assigns.file)
  end

  defp assign_chunked(conn, behavior, key) do
    case {key, behavior[key]} do
      {_, :not_chunked} ->
        assign(conn, :chunked, false)

      {_, {:chunked, number, timeout}} ->
        merge_assigns(conn, chunked: true, number: number, timeout: timeout)

      {:default, _} ->
        assign(conn, :chunked, false)

      _ ->
        assign_chunked(conn, behavior, :default)
    end
  end
end
