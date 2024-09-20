defmodule OnlineMockCookidoo.Auth.TokenController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMockCookidoo.Auth.JWTManager

  plug :secure_cache_headers
  plug :lock
  plug :client_auth
  plug :state_error

  def create(conn, %{
        "grant_type" => "authorization_code",
        "code" => "AuthorizationCode",
        "redirect_uri" => _
      }) do
    client_id = conn.assigns[:client_id]
    reset_iat(client_id)
    signer = JWTManager.signer(OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :algorithm]))
    id_token = JWTManager.generate_and_sign!(%{"client_id" => client_id}, signer)
    expires_in = JWTManager.get_token_expiration_time()

    render(conn, :create, id_token: id_token, expires_in: expires_in)
  end

  def create(conn, %{"grant_type" => "password", "username" => _, "password" => _}) do
    id_token = JWTManager.generate_and_sign!(%{}, JWTManager.signer(nil))
    expires_in = JWTManager.get_token_expiration_time()
    render(conn, :create, id_token: id_token, expires_in: expires_in)
  end

  def create(conn, %{"grant_type" => "refresh_token", "refresh_token" => "RefreshToken"}) do
    signer = JWTManager.signer(OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :algorithm]))
    id_token = JWTManager.generate_and_sign!(%{"client_id" => conn.assigns[:client_id]}, signer)
    expires_in = JWTManager.get_token_expiration_time()

    render(conn, :create, id_token: id_token, expires_in: expires_in)
  end

  def reset_iat(client_id) do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :auth_time]) do
      nil ->
        nil

      %{^client_id => _auth_time} ->
        OnlineMock.State.update(
          [OnlineMockCookidoo.Auth.Token, :auth_time],
          &Map.put(&1, client_id, :iat)
        )
    end
  end

  defp secure_cache_headers(conn, _opts) do
    conn = Plug.Conn.put_resp_header(conn, "pragma", "no-cache")
    Plug.Conn.put_resp_header(conn, "cache-control", "no-store, private")
  end

  defp state_error(conn, _opts) do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :error, conn.params["grant_type"]]) do
      nil ->
        conn

      error when is_binary(error) ->
        conn
        |> put_status(:bad_request)
        |> render(:create, error: error)
        |> halt()
    end
  end

  defp client_auth(conn, _opts) do
    user = OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user])
    pass = OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :pass])

    case Plug.BasicAuth.parse_basic_auth(conn) do
      {^user, ^pass} ->
        assign(conn, :client_id, user)

      _ ->
        conn
        |> Plug.BasicAuth.request_basic_auth()
        |> render(:create, error: "invalid_client")
        |> halt()
    end
  end

  defp lock(conn, _opts) do
    OnlineMock.LockHandle.await_unlock(__MODULE__)
    conn
  end
end
