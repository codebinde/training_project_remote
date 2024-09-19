defmodule Plug.LoggerMetadata do
  @moduledoc """
  A plug that adds `Logger` metadata to the process.

  ## Examples

  To use it, plug it into the desired module.

      plug Plug.LoggerMetadata, data: "some metadata"
  """

  @behaviour Plug

  @impl Plug
  def init(metadata), do: metadata

  @impl Plug
  def call(conn, metadata) do
    Logger.metadata(metadata)
    conn
  end
end
