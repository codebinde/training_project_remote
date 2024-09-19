defmodule OnlineMockCookidoo.Auth.JSONWebKeySetControllerTest do
  use OnlineMockCookidoo.ConnCase

  describe "show" do
    test "contains key", %{conn: conn} do
      conn = get(conn, ~p"/auth/jwks.json")

      assert %{
               "keys" => [
                 %{"kty" => "RSA", "e" => "AQAB", "n" => _, "kid" => "RS256 Key ID", "x5c" => _},
                 %{"crv" => "P-256", "kty" => "EC", "kid" => "ES256 Key ID", "x" => _, "y" => _}
               ]
             } = json_response(conn, 200)
    end

    test "contains new key ids after key cycle", %{conn: conn} do
      OnlineMock.Keywords.Cookidoo.Auth.cycle_published_signing_keys()
      conn = get(conn, ~p"/auth/jwks.json")

      assert %{
               "keys" => [
                 %{
                   "kty" => "RSA",
                   "e" => "AQAB",
                   "n" => _,
                   "kid" => "New RS256 Key ID",
                   "x5c" => _
                 },
                 %{
                   "crv" => "P-256",
                   "kty" => "EC",
                   "kid" => "New ES256 Key ID",
                   "x" => _,
                   "y" => _
                 }
               ]
             } = json_response(conn, 200)

      OnlineMock.Keywords.Cookidoo.Auth.reset_published_signing_keys()
    end
  end
end
