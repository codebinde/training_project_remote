defmodule Plug.State do
  @moduledoc """
  A plug that controls the state of `OnlineMock`.

  ## Options

  * `:filter` - A filter to be applied to the connection to determine the path to the stored state.
  * `:callback` - The callback to be invoked with conn, the state stored under path, and path
  determined via filter as the first three arguments.
  """

  require Logger

  @behaviour Plug

  @impl Plug
  def init(opts) do
    {Keyword.fetch!(opts, :filter), Keyword.fetch!(opts, :callback)}
  end

  @impl Plug
  def call(conn, {filter, callback}) do
    case filter.(conn) do
      nil ->
        conn

      path ->
        state = OnlineMock.State.get(path)
        callback.(conn, state, path)
    end
  end
end
