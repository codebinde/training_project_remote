defmodule OnlineMock.Plugs do
  @moduledoc false

  require Logger

  def delay(conn, otp_app) do
    case OnlineMock.State.get([:"delay_#{otp_app}_endpoint_response"]) do
      nil ->
        conn

      response_delay_server ->
        Process.sleep(response_delay_server)
        conn
    end
  end
end
