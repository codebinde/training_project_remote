defmodule OnlineMockCookidoo.Auth.EndSessionControllerTest do
  use OnlineMockCookidoo.ConnCase
  alias OnlineMockCookidoo.Auth.JWTManager

  describe "post method functionality" do
    test "redirects to redirect_uri", %{conn: conn} do
      redirect_uri = "cookidoo://example"

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

      conn =
        post(conn, ~p"/auth/end_session",
          post_logout_redirect_uri: redirect_uri,
          id_token_hint: id_token
        )

      assert response(conn, 302)
      redirected_to = redirected_to(conn)
      assert redirected_to =~ redirect_uri
    end

    test "non-matching client_id results in failure", %{conn: conn} do
      redirect_uri = "cookidoo://example"

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

      conn =
        post(conn, ~p"/auth/end_session",
          post_logout_redirect_uri: redirect_uri,
          id_token_hint: id_token,
          client_id: "wrong id"
        )

      assert response(conn, 400)
    end

    test "non-matching id_token_hint results in failure", %{conn: conn} do
      redirect_uri = "cookidoo://example"

      token = %{"iss" => "https://example.com", "aud" => JWTManager.get_aud_claim()}

      signer =
        JWTManager.signer(OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :algorithm]))

      id_token = JWTManager.generate_and_sign!(token, signer)

      conn =
        post(conn, ~p"/auth/end_session",
          post_logout_redirect_uri: redirect_uri,
          id_token_hint: id_token
        )

      assert response(conn, 400)

      token = %{"iss" => JWTManager.get_iss_claim(), "aud" => "wrong aud claim"}
      id_token = JWTManager.generate_and_sign!(token, signer)

      conn =
        post(conn, ~p"/auth/end_session",
          post_logout_redirect_uri: redirect_uri,
          id_token_hint: id_token
        )

      assert response(conn, 400)
    end

    test "bad redirect uri results in failure", %{conn: conn} do
      redirect_uri = "http://example.com"

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

      conn =
        post(conn, ~p"/auth/end_session",
          post_logout_redirect_uri: redirect_uri,
          id_token_hint: id_token
        )

      assert response(conn, 400)
    end

    test "no id_token_hint results in failure", %{conn: conn} do
      redirect_uri = "http://example.com"

      conn = post(conn, ~p"/auth/end_session", post_logout_redirect_uri: redirect_uri)

      assert response(conn, 400)
    end

    test "no redirect uri results in failure", %{conn: conn} do
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

      conn = post(conn, ~p"/auth/end_session", id_token_hint: id_token)

      assert response(conn, 400)
    end
  end

  describe "get method functionality" do
    test "redirect to redirect_uri", %{conn: conn} do
      redirect_uri = "cookidoo://example"

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

      conn =
        get(
          conn,
          ~p"/auth/end_session?post_logout_redirect_uri=" <>
            redirect_uri <>
            "&id_token_hint=" <>
            id_token <>
            "&client_id=nwot-live-v1"
        )

      assert response(conn, 302)
      redirected_to = redirected_to(conn)
      assert redirected_to =~ redirect_uri
    end
  end
end
