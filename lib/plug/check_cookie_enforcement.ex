defmodule Plug.CheckCookieEnforcement do
  @moduledoc """
  A plug that checks if required cookies are present and prohibited cookies are
  not present in client requests.

  Cookie requirement / prohibition rules have to be configured in a yaml file
  and its path has to be provided as environment variable "COOKIE_ENFORCEMENT_PATH"

  ## Options

  * `:endpoint` - The endpoint is required to determine domain specific cookie rules
  """

  require Logger

  import Plug.Conn

  @behaviour Plug

  @impl Plug
  def init(opts) do
    case Keyword.get(opts, :endpoint) do
      nil ->
        raise ArgumentError, ":endpoint is required"

      endpoint ->
        endpoint
    end
  end

  @impl Plug
  def call(conn, endpoint) do
    rules =
      Application.fetch_env!(:online_mock, endpoint)
      |> Keyword.take([:required_cookies, :prohibited_cookies])

    do_check_cookie_enforcement(conn, rules)
  end

  def do_check_cookie_enforcement(conn, []) do
    conn
  end

  def do_check_cookie_enforcement(conn, rules) do
    conn = fetch_cookies(conn)
    cookies = conn.cookies
    required = Keyword.fetch!(rules, :required_cookies)
    prohibited = Keyword.fetch!(rules, :prohibited_cookies)

    cond do
      required_missing?(required, cookies) ->
        Logger.debug(
          "Required cookies missing in client request. required=#{inspect(required)}, cookies=#{inspect(cookies)}"
        )

        conn
        |> send_resp(:forbidden, "")
        |> halt()

      prohibited_present?(prohibited, cookies) ->
        Logger.debug(
          "Prohibited cookies present in client request. prohibited=#{inspect(prohibited)}, cookies=#{inspect(cookies)}"
        )

        conn
        |> send_resp(:bad_request, "")
        |> halt()

      true ->
        conn
    end
  end

  defp required_missing?(required, cookies) do
    not Enum.all?(required, fn {key, value} -> Map.fetch(cookies, key) == {:ok, value} end)
  end

  defp prohibited_present?(prohib, cookies) do
    Enum.any?(prohib, fn {key, value} -> Map.fetch(cookies, key) == {:ok, value} end)
  end
end
