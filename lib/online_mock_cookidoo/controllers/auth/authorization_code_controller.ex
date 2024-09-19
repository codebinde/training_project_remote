defmodule OnlineMockCookidoo.Auth.AuthorizationCodeController do
  @moduledoc """
  [OpenID Connect Core 1.0 incorporating errata set 1](https://openid.net/specs/openid-connect-core-1_0.html)
  """

  use OnlineMockCookidoo, :controller

  plug :fetch_session
  plug :require_authenticated when action in [:show]
  plug :client_id
  plug :state_error

  def create(conn, params), do: show(conn, params)

  def show(
        conn,
        %{
          "response_type" => "code",
          "redirect_uri" => redirect_uri,
          "nonce" => nonce,
          "client_id" => client_id
        } = params
      ) do
    resp_params = Map.take(params, ["state"])

    with :ok <- validate_scope(resp_params, params) do
      store_nonce(nonce, client_id)
      resp_params = Map.merge(resp_params, %{"code" => "AuthorizationCode"})
      redirect_uri = add_query_params(redirect_uri, resp_params)
      redirect(conn, external: redirect_uri)
    else
      {:error, resp_params} ->
        redirect_uri = add_query_params(redirect_uri, resp_params)
        redirect(conn, external: redirect_uri)
    end
  end

  def show(
        conn,
        %{
          "response_type" => "code",
          "redirect_uri" => redirect_uri,
          "client_id" => client_id
        } = params
      ) do
    resp_params = Map.take(params, ["state"])

    with :ok <- validate_scope(resp_params, params) do
      store_nonce(nil, client_id)
      resp_params = Map.merge(resp_params, %{"code" => "AuthorizationCode"})
      redirect_uri = add_query_params(redirect_uri, resp_params)
      redirect(conn, external: redirect_uri)
    else
      {:error, resp_params} ->
        redirect_uri = add_query_params(redirect_uri, resp_params)
        redirect(conn, external: redirect_uri)
    end
  end

  defp require_authenticated(conn, _opts) do
    if get_session(conn, :authenticated) do
      configure_session(conn, drop: true)
    else
      conn
      |> put_session(:return_to, current_path(conn))
      |> redirect(to: ~p"/auth/sessions/new")
      |> halt()
    end
  end

  defp store_nonce(nonce, client_id) do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :nonce]) do
      nil ->
        OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :nonce], %{client_id => nonce})

      _ ->
        OnlineMock.State.update(
          [OnlineMockCookidoo.Auth.Token, :nonce],
          &Map.put(&1, client_id, nonce)
        )
    end
  end

  defp state_error(conn, _opts) do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth, :auth_request_error]) do
      nil ->
        conn

      "wrong_state" ->
        %{conn | params: Map.put(conn.params, "state", "WRONG")}

      error when is_binary(error) ->
        redirect_uri = conn.params["redirect_uri"]
        resp_params = Map.take(conn.params, ["state"])
        resp_params = Map.merge(resp_params, %{"error" => error})
        redirect_uri = add_query_params(redirect_uri, resp_params)

        conn |> redirect(external: redirect_uri) |> halt()
    end
  end

  defp client_id(conn, _opts) do
    user = OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user])

    case conn.params["client_id"] do
      ^user ->
        conn

      _ ->
        conn |> send_resp(:bad_request, "") |> halt()
    end
  end

  defp validate_scope(resp_params, params) do
    %{"scope" => scope} = params
    true = scope |> String.split() |> Enum.member?("openid")
    :ok
  rescue
    _ ->
      {:error, Map.merge(resp_params, %{"error" => "invalid_scope"})}
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
