defmodule Plug.EventLog do
  @moduledoc """
  A plug that logs events.

  ## Options

  * `:event` - The event to be logged (required).
  * `:conn_keys` - Defines the keys of the map to be logged. The map is extracted from the given
    `Plug.Conn`.
  """

  @behaviour Plug

  @impl Plug
  def init(opts) do
    case Keyword.get(opts, :event) do
      nil ->
        raise ArgumentError, ":event required"

      event ->
        {event, Keyword.get(opts, :conn_keys, [])}
    end
  end

  @impl Plug
  def call(conn, {event, keys}) do
    OnlineMock.log_event(event, Map.take(conn, keys))
    conn
  end
end
