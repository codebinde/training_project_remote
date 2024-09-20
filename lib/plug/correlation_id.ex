defmodule Plug.CorrelationID do
  @moduledoc """
  A plug that checks the header `correlation-id` contains exactly one item.

  In case `correlation-id` is missing an empty response with status `:bad_request` is sent and the
  Plug pipeline is halted.
  """

  require Logger

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(_opts), do: []

  @impl Plug
  def call(conn, _opts) do
    case get_req_header(conn, "correlation-id") do
      [_] = correlation_id ->
        Logger.debug("correlation-id accepted: correlation-id=#{inspect(correlation_id)}")
        conn

      correlation_id ->
        Logger.debug("correlation-id incorrect: correlation-id=#{inspect(correlation_id)}")

        conn
        |> send_resp(:bad_request, "")
        |> halt()
    end
  end
end
