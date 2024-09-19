defmodule OnlineMockCookidoo.StolenDevices.StatusController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug Plug.StateAssign, key: :stolen_devices_status, default: %{blocked: false}
  plug :maybe_send_error

  def show(conn, _params) do
    json(conn, conn.assigns[:stolen_devices_status])
  end

  defp maybe_send_error(conn, _opts) do
    case conn.assigns[:stolen_devices_status] do
      {:error, status} ->
        conn |> put_status(status) |> json(Plug.Conn.Status.reason_phrase(status)) |> halt()

      _ ->
        conn
    end
  end
end
