defmodule OnlineMockCookidoo.Auth.DeviceAuthorizationController do
  @moduledoc """
  [RFC8628: OAuth 2.0 Device Authorization Grant](https://datatracker.ietf.org/doc/html/rfc8628)
  """

  require Logger

  use OnlineMockCookidoo, :controller

  alias OnlineMockCookidoo.Auth.JWTManager
  alias OnlineMockCookidoo.Auth.TokenController

  plug :check_parameters

  @device_code "DeviceCode"
  @user_code "UserCode"
  @expires_in 8600
  @interval 5

  def create(
        conn,
        %{"client_id" => client_id, "scope" => _scope, "response_type" => _response_type}
      ) do
    verification_uri =
      OnlineMockCookidoo.Endpoint.url() <> "/auth/device-verification?client_id=" <> client_id

    verification_uri_complete = verification_uri <> "&user_code=" <> @user_code

    resp_params =
      %{
        "device_code" => @device_code,
        "user_code" => @user_code,
        "verification_uri" => verification_uri,
        "verification_uri_complete" => verification_uri_complete,
        "expires_in" => @expires_in,
        "interval" => @interval
      }

    expiration_time = NaiveDateTime.add(OnlineMock.DateTime.utc_now(), @expires_in)

    OnlineMock.State.put([OnlineMockCookidoo.Auth, :user_auth], %{
      device_code: @device_code,
      expiration: expiration_time
    })

    OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], :pending)

    json(conn, resp_params)
  end

  def create(
        conn,
        %{
          "client_id" => client_id,
          "grant_type" => "urn:ietf:params:oauth:grant-type:device_code",
          "device_code" => device_code
        }
      ) do
    verify_valid_request(device_code)
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :user_auth], nil)

    case check_for_user_authentication(client_id) do
      :ok ->
        TokenController.reset_iat(client_id)

        signer =
          JWTManager.signer(OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :algorithm]))

        id_token = JWTManager.generate_and_sign!(%{"client_id" => client_id}, signer)
        expires_in = JWTManager.get_token_expiration_time()

        response = %{
          id_token: id_token,
          expires_in: expires_in,
          access_token: "AccessToken",
          refresh_token: "RefreshToken",
          token_type: "Bearer"
        }

        json(conn, response)

      :expired ->
        conn |> send_resp(:bad_request, "expired_token") |> halt()

      :pending ->
        conn |> send_resp(:bad_request, "authentication_pending") |> halt()

      :error ->
        conn |> send_resp(:bad_request, "access_denied") |> halt()
    end
  end

  defp verify_valid_request(code_received) do
    %{device_code: code_sent, expiration: expiration_time} =
      OnlineMock.State.get([OnlineMockCookidoo.Auth, :user_auth], %{
        device_code: nil,
        expiration: nil
      })

    case code_sent do
      ^code_received ->
        verify_not_expired(expiration_time)

      nil ->
        OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], nil)
    end
  end

  defp verify_not_expired(time) do
    current = OnlineMock.DateTime.utc_now()

    case NaiveDateTime.compare(current, time) do
      :lt ->
        :ok

      :gt ->
        OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], :expired)
    end
  end

  defp check_parameters(conn, _opts) do
    user = OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user])
    Logger.info("User is: #{inspect(user)}")

    case conn.params["client_id"] do
      ^user ->
        conn

      _ ->
        conn |> send_resp(:bad_request, "") |> halt()
    end
  end

  defp check_for_user_authentication(user) do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user]) do
      ^user ->
        OnlineMock.State.get([OnlineMockCookidoo.Auth, :device_auth_user_confirm], :error)

      _ ->
        :error
    end
  end
end
