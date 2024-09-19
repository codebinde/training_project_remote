defmodule Plug.UserAgent do
  @moduledoc """
  A plug that checks the header `user-agent`.

  ## Options

  * `:key` - The `key` that points to the user-agent stored in `OnlineMock.State` (required).

  In case a user-agent is stored in `OnlineMock.State` under `[Plug.UserAgent, key]` the header
  `user-agent` must contain a single item matching the stored value. Otherwise a response is sent
  with status `:bad_request` and the Plug pipeline is halted.
  """

  require Logger

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(opts) do
    case Keyword.get(opts, :key) do
      nil ->
        raise ArgumentError, ":key required"

      key ->
        key
    end
  end

  @impl Plug
  def call(conn, key) do
    case OnlineMock.State.get([__MODULE__, key]) do
      nil ->
        conn

      user_agent ->
        accept_user_agent(conn, user_agent)
    end
  end

  defp accept_user_agent(conn, acceptable_user_agent) do
    case get_req_header(conn, "user-agent") do
      [^acceptable_user_agent] ->
        Logger.debug("user-agent accepted: user-agent=#{inspect(acceptable_user_agent)}")
        conn

      user_agent ->
        Logger.debug(
          "user-agent does not match #{inspect(acceptable_user_agent)}: " <>
            "user-agent=#{inspect(user_agent)}"
        )

        conn
        |> send_resp(:bad_request, "")
        |> halt()
    end
  end
end
