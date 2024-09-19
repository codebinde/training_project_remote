defmodule Plug.AccessTokenLogger do
  @moduledoc """
  A plug that logs the AccessToken authorization header received by endpoints
  """

  @authorization_header "authorization"

  require Logger

  @behaviour Plug

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, opts) do
    %{host: host, req_headers: req_headers, request_path: request_path} = conn

    auth_header =
      Enum.filter(req_headers, fn {header, content} -> filter_token_watchlist(header, content) end)

    if length(auth_header) == 1 do
      [{_header, token}] = auth_header

      case opts do
        :expect_no_token ->
          Logger.notice(
            "Unexpected transmission of Token in request header. token=#{inspect(token, pretty: true)}"
          )

          Logger.debug("req_headers=#{inspect(req_headers, pretty: true)}")

          counter = OnlineMock.State.get([:access_token_found])

          case counter do
            nil ->
              OnlineMock.State.put([:access_token_found], 1)

              OnlineMock.State.put(
                [:access_token_values],
                [%{token_number: 1, token_value: token}]
              )

            counter when is_number(counter) ->
              OnlineMock.State.put([:access_token_found], counter + 1)

              OnlineMock.State.update(
                [:access_token_values],
                &List.insert_at(&1, -1, %{token_number: counter + 1, token_value: token})
              )

            _ ->
              Logger.error("Something went wrong.")
          end

        :expect_token ->
          Logger.debug(
            "Token transmitted in request header." <>
              " host=#{inspect(host, pretty: true)}," <>
              " request_path=#{inspect(request_path, pretty: true)}," <>
              " token=#{inspect(token, pretty: true)}"
          )

        _ ->
          Logger.debug("Authorization header transmitted in request.")
      end
    end

    conn
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
