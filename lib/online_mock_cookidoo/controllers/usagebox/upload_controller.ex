defmodule OnlineMockCookidoo.Usagebox.UploadController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def update(conn, _params) do
    conn
    |> read_body()
    |> parse_file(open_file())
    |> send_resp(:created, "")
  end

  defp open_file do
    unique = System.unique_integer([:positive, :monotonic])
    path = Path.join(upload_dir(), "usagebox-#{unique}.tar.gz")
    {File.open!(path, [:binary, :write, :raw, :exclusive, :delayed_write]), path}
  end

  defp parse_file({:more, data, conn}, {device, _} = file) do
    :ok = IO.binwrite(device, data)

    conn
    |> read_body()
    |> parse_file(file)
  end

  defp parse_file({:ok, data, conn}, {device, path}) do
    :ok = IO.binwrite(device, data)
    :ok = File.close(device)
    OnlineMock.log_event(:cookidoo_usagebox_upload, path)
    conn
  end

  defp upload_dir do
    dir =
      OnlineMock.State.get([__MODULE__, :upload_dir]) ||
        raise Plug.UploadError, "no upload directory configured"

    case File.mkdir(dir) do
      :ok ->
        dir

      {:error, :eexist} ->
        dir

      {:error, reason} ->
        raise Plug.UploadError,
              "create upload directory #{inspect(dir)} failed with reason #{inspect(reason)}"
    end
  end
end
