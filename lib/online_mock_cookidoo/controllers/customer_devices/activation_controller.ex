defmodule OnlineMockCookidoo.CustomerDevices.ActivationController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    case get_status() do
      nil ->
        conn |> put_status(:bad_request) |> json([%{code: "deviceIdNotFoundOrInvalid"}])

      status when is_map(status) ->
        json(conn, status)
    end
  end

  def create(conn, %{
        "backendNumber" => backend_number,
        "chipId" => chip_id,
        "frontendNumber" => frontend_number,
        "serialNumber" => serial_number
      }) do
    put_status(%{
      "backendNumber" => backend_number,
      "chipId" => chip_id,
      "frontendNumber" => frontend_number,
      "deviceId" => :crypto.hash(:sha256, serial_number) |> Base.encode16(case: :lower)
    })

    json(conn, %{trialSubscriptionAvailable: true})
  end

  def delete(conn, _params) do
    pop_status()
    OnlineMock.State.put([:device_deactivation_body], conn.body_params)
    json(conn, %{})
  end

  defp get_status do
    OnlineMock.State.get([Access.key(__MODULE__, %{}), :status])
  end

  defp put_status(status) do
    OnlineMock.State.put([Access.key(__MODULE__, %{}), :status], status)
  end

  defp pop_status do
    OnlineMock.State.pop([__MODULE__, :status])
  end
end
