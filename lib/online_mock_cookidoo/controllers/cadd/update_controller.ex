defmodule OnlineMockCookidoo.CADD.UpdateController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, %{"minFirmware" => min_firmware}) do
    case parse_requirement(min_firmware) do
      :error ->
        send_resp(conn, :bad_request, "minFirmware has wrong format")

      _requirement ->
        json(conn, [])
    end
  end

  defp parse_requirement(min_firmware) do
    min_firmware = attach_patch_version(min_firmware)
    Version.parse_requirement(">= " <> min_firmware)
  end

  defp attach_patch_version(min_firmware) do
    if 2 == length(String.split(min_firmware, ".")) do
      min_firmware <> ".0"
    else
      min_firmware
    end
  end
end
