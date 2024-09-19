defmodule OnlineMockCookidoo.Auth.EndSessionController do
  @moduledoc """
  [OpenID Connect RP-Initiated Logout 1.0](https://openid.net/specs/openid-connect-rpinitiated-1_0.html)
  """

  use OnlineMockCookidoo, :controller

  alias OnlineMockCookidoo.Auth.JWTManager

  plug :id_token_hint
  plug :post_logout_redirect_uri
  plug :client_id

  def create(conn, params), do: show(conn, params)

  def show(
        conn,
        %{"post_logout_redirect_uri" => redirect_uri, "id_token_hint" => _} = params
      ) do
    resp_params = Map.take(params, ["state"])
    redirect_uri = add_query_params(redirect_uri, resp_params)

    conn
    |> clear_session()
    |> redirect(external: redirect_uri)
  end

  defp id_token_hint(conn, _opts) do
    case conn.params["id_token_hint"] do
      nil ->
        conn |> send_resp(:bad_request, "no id_token_hint") |> halt()

      token ->
        validate_id_token(conn, token)
    end
  end

  defp post_logout_redirect_uri(conn, _opts) do
    case conn.params["post_logout_redirect_uri"] do
      nil ->
        conn |> send_resp(:bad_request, "post logout redirect expected") |> halt()

      uri ->
        if String.starts_with?(uri, "cookidoo://") do
          conn
        else
          conn |> send_resp(:bad_request, "bad post logout redirect") |> halt()
        end
    end
  end

  defp client_id(conn, _opts) do
    {:ok, %{"aud" => token_client_id}} = Joken.peek_claims(conn.params["id_token_hint"])

    case conn.params["client_id"] do
      nil ->
        conn

      ^token_client_id ->
        conn

      _other_id ->
        conn |> send_resp(:bad_request, "bad client id") |> halt()
    end
  end

  defp validate_id_token(conn, token) do
    our_issuer = JWTManager.get_iss_claim()
    our_aud = JWTManager.get_aud_claim()

    case Joken.peek_claims(token) do
      {:ok, %{"iss" => ^our_issuer, "aud" => ^our_aud}} ->
        conn

      _ ->
        conn |> send_resp(:bad_request, "bad token hint") |> halt()
    end
  end

  defp add_query_params(uri, params) do
    uri
    |> URI.parse()
    |> Map.update(
      :query,
      nil,
      fn
        nil -> URI.encode_query(params)
        query -> query |> URI.decode_query(params) |> URI.encode_query()
      end
    )
    |> URI.to_string()
  end
end
