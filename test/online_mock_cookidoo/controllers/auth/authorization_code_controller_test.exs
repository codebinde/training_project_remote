defmodule OnlineMockCookidoo.Auth.AuthorizationCodeControllerTest do
  use OnlineMockCookidoo.ConnCase

  test "redirects to redirect_uri", %{conn: conn} do
    redirect_uri = "http://example.com"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "nwot-live-v1",
        redirect_uri: redirect_uri,
        scope: "openid"
      )

    redirected_to = redirected_to(conn)
    assert redirected_to =~ redirect_uri
    assert redirected_to =~ "code=AuthorizationCode"
  end

  test "supports GET", %{conn: conn} do
    conn = init_test_session(conn, %{authenticated: true})
    redirect_uri = "http://example.com"

    params = [
      response_type: "code",
      client_id: "nwot-live-v1",
      redirect_uri: redirect_uri,
      scope: "openid"
    ]

    conn = get(conn, ~p"/auth/authorization-code?#{params}")
    redirected_to = redirected_to(conn)
    assert redirected_to =~ redirect_uri
    assert redirected_to =~ "code=AuthorizationCode"
  end

  test "preserves query parameters when redirecting", %{conn: conn} do
    redirect_uri = "http://example.com?key=value"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "nwot-live-v1",
        redirect_uri: redirect_uri,
        scope: "openid"
      )

    %{query: query} = redirected_to(conn) |> URI.parse()
    assert URI.decode_query(query) == %{"key" => "value", "code" => "AuthorizationCode"}
  end

  test "includes state in query parameters when redirecting", %{conn: conn} do
    redirect_uri = "http://example.com"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "nwot-live-v1",
        redirect_uri: redirect_uri,
        scope: "openid",
        state: "State"
      )

    redirected_to = redirected_to(conn) |> URI.parse()

    assert URI.decode_query(redirected_to.query) == %{
             "state" => "State",
             "code" => "AuthorizationCode"
           }
  end

  test "denies access in case of missing scope", %{conn: conn} do
    redirect_uri = "http://example.com"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "nwot-live-v1",
        redirect_uri: redirect_uri
      )

    assert redirected_to(conn) =~ "error=invalid_scope"
  end

  test "denies access in case scope does not contain value openid", %{conn: conn} do
    redirect_uri = "http://example.com"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "nwot-live-v1",
        redirect_uri: redirect_uri,
        scope: "profile email"
      )

    assert redirected_to(conn) =~ "error=invalid_scope"
  end

  test "validates client_id", %{conn: conn} do
    redirect_uri = "http://example.com"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "WRONG",
        redirect_uri: redirect_uri,
        scope: "openid"
      )

    assert response(conn, 400)
  end

  test "allows configuring of server-side errors", %{conn: conn} do
    OnlineMock.Keywords.Cookidoo.Auth.configure_auth_error("custom_error")
    redirect_uri = "http://example.com"

    conn =
      post(conn, ~p"/auth/authorization-code",
        response_type: "code",
        client_id: "nwot-live-v1",
        redirect_uri: redirect_uri,
        scope: "openid"
      )

    assert redirected_to(conn) =~ "error=custom_error"
    OnlineMock.Keywords.Cookidoo.Auth.configure_auth_error()
  end

  test "stores nonce correctly", %{conn: conn} do
    post(conn, ~p"/auth/authorization-code",
      response_type: "code",
      client_id: "nwot-live-v1",
      redirect_uri: "http://example.com",
      scope: "openid",
      nonce: "Nonce"
    )

    %{"nwot-live-v1" => nonce} = OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :nonce])
    assert "Nonce" == nonce
  end
end
