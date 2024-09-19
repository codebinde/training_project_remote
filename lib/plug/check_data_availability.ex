defmodule Plug.CheckDataAvailability do
  @moduledoc """
  A plug that checks for ets data availability, and returns 404 if not available.

  ## Options

  * `table` - The ets table of the resource
  * `path_generator`  - A tuple containing module, function, arguments
      for a function accepting conn and arguments for generating
      the path to the related data.
  """

  require Logger

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(opts) do
    if Keyword.get(opts, :table) == nil do
      raise ArgumentError, ":table required"
    end

    if Keyword.get(opts, :path_generator) == nil do
      raise ArgumentError, ":path_generator mfa required"
    end

    opts |> Enum.into(%{})
  end

  @impl Plug
  def call(conn, %{table: table, path_generator: {mod, fun, args}}) do
    path = apply(mod, fun, [conn | args])

    if :ets.member(table, path) do
      conn
    else
      conn
      |> send_resp(:not_found, "")
      |> halt()
    end
  end
end
