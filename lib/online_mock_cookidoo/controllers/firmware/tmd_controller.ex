defmodule OnlineMockCookidoo.Firmware.TMDController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__
  plug :sleep, [:firmware_tmd_delay]
  plug :await_unlock, :firmware_tmd_lock
  plug :put_state, [:firmware_tmd]
  plug :halt_on_error

  def show(conn, %{
        "firmwareVersion" => firmware_version,
        "hardwareVersion" => hardware_version,
        "id" => id
      }) do
    {version, path} = conn.assigns[:state]
    name = path |> Path.basename() |> Path.rootname()

    links = %{
      self:
        current_url(conn, %{
          firmwareVersion: firmware_version,
          hardwareVersion: hardware_version,
          id: id
        }),
      download: url(~p"/firmware/tmd/#{name}")
    }

    render(conn, :show, links: links, version: version)
  end

  defp sleep(conn, path) do
    if delay = OnlineMock.State.get(path), do: Process.sleep(delay)
    conn
  end

  defp await_unlock(conn, path) do
    OnlineMock.LockHandle.await_unlock(path)
    conn
  end

  defp put_state(conn, path) do
    state = OnlineMock.State.get(path)
    assign(conn, :state, state)
  end

  defp halt_on_error(conn, _opts) do
    case conn.assigns[:state] do
      nil ->
        conn |> send_resp(:no_content, "") |> halt()

      error_code when is_atom(error_code) ->
        conn |> send_resp(error_code, "") |> halt()

      _ ->
        conn
    end
  end
end
