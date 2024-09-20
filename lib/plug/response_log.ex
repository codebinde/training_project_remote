defmodule Plug.ResponseLog do
  @moduledoc """
  A plug that logs responses.
  """

  require Logger

  @behaviour Plug

  @impl Plug
  def init(_opts), do: []

  @impl Plug
  def call(conn, _) do
    Plug.Conn.register_before_send(conn, fn conn ->
      Logger.debug("conn=#{inspect(conn, limit: :infinity, pretty: true)}")

      conn
    end)
  end
end
