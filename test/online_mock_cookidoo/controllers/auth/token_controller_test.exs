defmodule OnlineMockCookidoo.Auth.TokenControllerTest do
  use OnlineMockCookidoo.ConnCase

  test "requires client authentication", %{conn: conn} do
    conn =
      conn
      |> put_req_header("authorization", Plug.BasicAuth.encode_basic_auth("unknown", "unknown"))
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    assert ["no-store, private"] == get_resp_header(conn, "cache-control")
    assert ["no-cache"] == get_resp_header(conn, "pragma")

    assert json_response(conn, 401) == %{"error" => "invalid_client"}
  end

  test "issues tokens for grand_type=authorization_code", %{conn: conn} do
    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    assert ["no-store, private"] == get_resp_header(conn, "cache-control")
    assert ["no-cache"] == get_resp_header(conn, "pragma")

    assert %{
             "access_token" => "AccessToken",
             "token_type" => "Bearer",
             "expires_in" => 3600,
             "refresh_token" => "RefreshToken",
             "id_token" => id_token
           } = json_response(conn, 200)

    assert {:ok, %{"alg" => "RS256", "kid" => "RS256 Key ID"}} = Joken.peek_header(id_token)

    assert {:ok,
            %{
              "aud" => "nwot-live-v1",
              "email" => "QA_INT@vorwerk.de",
              "family_name" => "Family Name",
              "given_name" => "Given Name",
              "iss" => iss,
              "sub" => "Subject"
            }} = Joken.peek_claims(id_token)

    assert iss == OnlineMockCookidoo.Endpoint.url() <> "/auth"
  end

  test "issues tokens for grand_type=refresh_token", %{conn: conn} do
    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token", grant_type: "refresh_token", refresh_token: "RefreshToken")

    assert ["no-store, private"] == get_resp_header(conn, "cache-control")
    assert ["no-cache"] == get_resp_header(conn, "pragma")

    assert %{
             "access_token" => "AccessToken",
             "token_type" => "Bearer",
             "expires_in" => 3600,
             "refresh_token" => "RefreshToken",
             "id_token" => id_token
           } = json_response(conn, 200)

    {:ok, claims} = Joken.peek_claims(id_token)
    assert false == Map.has_key?(claims, "nonce")
  end

  test "cycles keys correctly", %{conn: conn} do
    OnlineMock.Keywords.Cookidoo.Auth.configure_new_token_signing_keys()

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    assert {:ok, %{"alg" => "RS256", "kid" => "New RS256 Key ID"}} = Joken.peek_header(id_token)

    OnlineMock.Keywords.Cookidoo.Auth.reset_token_signing_keys()
  end

  test "signing with elliptic curves is supported", %{conn: conn} do
    OnlineMock.Keywords.Cookidoo.Auth.configure_token_signing_with_es256()

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    assert {:ok, %{"alg" => "ES256", "kid" => "ES256 Key ID"}} = Joken.peek_header(id_token)
    OnlineMock.Keywords.Cookidoo.Auth.reset_token_signing()
  end

  test "token endpoint can send configured errors", %{conn: conn} do
    OnlineMock.Keywords.Cookidoo.Auth.configure_error("custom_grant_type", "custom_error")

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "custom_grant_type",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    assert %{
             "error" => "custom_error"
           } = json_response(conn, 400)

    OnlineMock.Keywords.Cookidoo.Auth.configure_error("custom_grant_type")
  end

  test "token endpoint can be configured to send wrong issuer claim", %{conn: conn} do
    OnlineMock.Keywords.Cookidoo.Auth.configure_wrong_iss_claim()

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {_, %{"iss" => iss}} = Joken.peek_claims(id_token)

    assert "https://invalid_issuer.example.com/auth" == iss

    OnlineMock.Keywords.Cookidoo.Auth.reset_iss_claim()
  end

  test "token endpoint can be configured to send wrong audience claim", %{conn: conn} do
    OnlineMock.Keywords.Cookidoo.Auth.configure_wrong_aud_claim()

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {_, %{"aud" => audience}} = Joken.peek_claims(id_token)

    assert "WRONG AUDIENCE" == audience

    OnlineMock.Keywords.Cookidoo.Auth.reset_aud_claim()
  end

  test "nonce given in previous auth request is correctly sent", %{conn: conn} do
    post(conn, ~p"/auth/authorization-code",
      response_type: "code",
      client_id: "nwot-live-v1",
      redirect_uri: "http://example.com",
      scope: "openid",
      nonce: "Nonce"
    )

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    assert {:ok, %{"nonce" => "Nonce"}} = Joken.peek_claims(id_token)
  end

  test "nonce omitted if not sent in previous auth request", %{conn: conn} do
    post(conn, ~p"/auth/authorization-code",
      response_type: "code",
      client_id: "nwot-live-v1",
      redirect_uri: "http://example.com",
      scope: "openid"
    )

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {:ok, claims} = Joken.peek_claims(id_token)
    assert false == Map.has_key?(claims, "nonce")
  end

  test "auth_time claim is identical to initial auth time", %{conn: conn} do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], %{"nwot-live-v1" => :iat})

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {:ok, %{"auth_time" => auth_time, "iat" => iat}} = Joken.peek_claims(id_token)
    assert auth_time == iat

    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], %{
      "nwot-live-v1" => auth_time - 2
    })

    conn =
      conn
      |> post(~p"/auth/token",
        grant_type: "refresh_token",
        refresh_token: "RefreshToken",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {:ok, %{"auth_time" => new_auth_time}} = Joken.peek_claims(id_token)
    assert auth_time - 2 == new_auth_time

    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], nil)
  end

  test "auth_time claim correctly resets upon new authorization", %{conn: conn} do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], %{"nwot-live-v1" => :error})

    conn =
      conn
      |> put_req_header(
        "authorization",
        Plug.BasicAuth.encode_basic_auth(
          "nwot-live-v1",
          "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"
        )
      )
      |> post(~p"/auth/token",
        grant_type: "refresh_token",
        refresh_token: "RefreshToken",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {:ok, %{"auth_time" => auth_time}} = Joken.peek_claims(id_token)
    assert auth_time == "error"

    conn =
      conn
      |> post(~p"/auth/token",
        grant_type: "authorization_code",
        code: "AuthorizationCode",
        redirect_uri: "http://example.com",
        client_id: "ClientID"
      )

    %{"id_token" => id_token} = json_response(conn, 200)

    {:ok, %{"auth_time" => auth_time, "iat" => iat}} = Joken.peek_claims(id_token)

    assert auth_time == iat
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], nil)
  end
end
