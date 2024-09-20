defmodule OnlineMockCookidoo.Auth.DeviceAuthorizationCodeControllerTest do
  use OnlineMockCookidoo.ConnCase

  test "correct response to device authorization request", %{conn: conn} do
    conn =
      post(conn, ~p"/auth/device-authorization",
        response_type: "device_code",
        client_id: "nwot-live-v1",
        scope: "openid"
      )

    verification_uri =
      OnlineMockCookidoo.Endpoint.url() <> "/auth/device-verification?client_id=nwot-live-v1"

    verification_uri_complete = verification_uri <> "&user_code=UserCode"

    assert %{
             "verification_uri" => ^verification_uri,
             "verification_uri_complete" => ^verification_uri_complete,
             "device_code" => "DeviceCode",
             "expires_in" => 8600,
             "interval" => 5
           } = json_response(conn, 200)
  end

  test "refuse when client_id incorrect", %{conn: conn} do
    conn =
      post(conn, ~p"/auth/device-authorization",
        response_type: "device_code",
        client_id: "unknown_id",
        scope: "openid"
      )

    assert response(conn, 400)
  end

  test "send authentication pending signal on auth start", %{conn: conn} do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], :pending)

    OnlineMock.State.put([OnlineMockCookidoo.Auth, :user_auth], %{
      device_code: "DeviceCode",
      expiration: NaiveDateTime.add(NaiveDateTime.utc_now(), 8600)
    })

    conn =
      post(conn, ~p"/auth/device-authorization",
        client_id: "nwot-live-v1",
        grant_type: "urn:ietf:params:oauth:grant-type:device_code",
        device_code: "DeviceCode"
      )

    assert response(conn, 400)

    assert conn.resp_body =~ "authentication_pending"
  end

  test "send token on user authentication", %{conn: conn} do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], :ok)

    OnlineMock.State.put([OnlineMockCookidoo.Auth, :user_auth], %{
      device_code: "DeviceCode",
      expiration: NaiveDateTime.add(NaiveDateTime.utc_now(), 8600)
    })

    conn =
      post(conn, ~p"/auth/device-authorization",
        client_id: "nwot-live-v1",
        grant_type: "urn:ietf:params:oauth:grant-type:device_code",
        device_code: "DeviceCode"
      )

    assert %{
             "access_token" => "AccessToken",
             "token_type" => "Bearer",
             "expires_in" => 3600,
             "refresh_token" => "RefreshToken",
             "id_token" => id_token
           } = json_response(conn, 200)

    assert {:ok,
            %{
              "aud" => "nwot-live-v1",
              "email" => "QA_INT@vorwerk.de",
              "family_name" => "Family Name",
              "given_name" => "Given Name",
              "sub" => "Subject"
            }} = Joken.peek_claims(id_token)
  end

  test "token request too late", %{conn: conn} do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :user_auth], %{
      device_code: "DeviceCode",
      expiration: NaiveDateTime.add(NaiveDateTime.utc_now(), -8600)
    })

    conn =
      post(conn, ~p"/auth/device-authorization",
        client_id: "nwot-live-v1",
        grant_type: "urn:ietf:params:oauth:grant-type:device_code",
        device_code: "DeviceCode"
      )

    assert response(conn, 400)

    assert conn.resp_body =~ "expired_token"
  end

  test "token request before auth request", %{conn: conn} do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], nil)

    conn =
      post(conn, ~p"/auth/device-authorization",
        client_id: "nwot-live-v1",
        grant_type: "urn:ietf:params:oauth:grant-type:device_code",
        device_code: "DeviceCode"
      )

    assert response(conn, 400)

    assert conn.resp_body =~ "access_denied"
  end
end
