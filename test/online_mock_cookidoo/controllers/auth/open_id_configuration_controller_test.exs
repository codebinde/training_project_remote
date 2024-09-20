defmodule OnlineMockCookidoo.Auth.OpenIDConfigurationControllerTest do
  use OnlineMockCookidoo.ConnCase

  describe "show" do
    test "shows configuration", %{conn: conn} do
      conn = get(conn, ~p"/auth/.well-known/openid-configuration")

      assert %{
               "issuer" => issuer,
               "authorization_endpoint" => authorization_endpoint,
               "token_endpoint" => token_endpoint,
               "jwks_uri" => jwks_uri,
               "device_authorization_endpoint" => device_authorization_endpoint
             } = json_response(conn, 200)

      assert issuer == OnlineMockCookidoo.Endpoint.url() <> "/auth"
      assert authorization_endpoint == url(~p"/auth/authorization-code")
      assert token_endpoint == url(~p"/auth/token")
      assert jwks_uri == url(~p"/auth/jwks.json")
      assert device_authorization_endpoint == url(~p"/auth/device-authorization")
    end
  end
end
