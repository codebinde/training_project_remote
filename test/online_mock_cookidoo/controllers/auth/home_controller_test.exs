defmodule OnlineMockCookidoo.Auth.HomeControllerTest do
  use OnlineMockCookidoo.ConnCase

  describe "show" do
    test "contains links", %{conn: conn} do
      conn = get(conn, ~p"/auth/.well-known/home")

      assert %{"_links" => %{"auth:resource-owner-password-flow" => %{"href" => href}}} =
               json_response(conn, 200)

      assert href == url(~p"/auth/token")
    end
  end
end
