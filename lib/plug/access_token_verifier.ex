defmodule Plug.AccessTokenVerifier do
  @moduledoc """
  A plug that verifies the AccessToken authorization header received by endpoints and halts
  when no correct AccessToken is sent
  """

  require Logger

  import Plug.Conn

  @authorization_header "authorization"

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, _opts) do
    %{req_headers: req_headers} = conn

    auth_header =
      Enum.filter(req_headers, fn {header, content} -> filter_token_watchlist(header, content) end)

    if length(auth_header) == 1 do
      conn
    else
      Logger.debug("req_headers=#{inspect(req_headers, limit: :infinity, pretty: true)}")

      conn
      |> send_resp(:unauthorized, "Wrong or no access token.")
      |> halt()
    end
  end

  defp filter_token_watchlist(header, content) do
    if header == @authorization_header do
      case OnlineMock.State.get([:access_token_watchlist]) do
        [] ->
          true

        watchlist ->
          content in watchlist
      end
    end
  end
end
