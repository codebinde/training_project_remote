defmodule Plug.StateAssign do
  @moduledoc """
  A plug that assigns a state of `OnlineMock` to the connection.

  The value of the state is assigned to the key of the state.

  ## Options

  * `:key` - The key of the state
  * `:default` - A default value (optional)
  """

  @behaviour Plug

  @impl Plug
  def init(opts) do
    {Keyword.fetch!(opts, :key), Keyword.get(opts, :default)}
  end

  @impl Plug
  def call(conn, {key, default}) do
    value = OnlineMock.State.get([key], default)
    Plug.Conn.assign(conn, key, value)
  end
end
