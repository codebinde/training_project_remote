defmodule OnlineMockCookidoo.HomeControllerTest do
  use OnlineMockCookidoo.ConnCase

  describe "show" do
    test "lists links", %{conn: conn} do
      conn = get(conn, ~p"/.well-known/home/LANG")
      links = json_response(conn, 200)["_links"]

      assert links["tmde2:stolen-devices"]["href"] == url(~p"/stolen-devices/.well-known/home")
    end

    test "meta properties", %{conn: conn} do
      conn = get(conn, ~p"/.well-known/home/LANG")
      meta = json_response(conn, 200)["meta"]

      assert meta["ResourceOwnerPasswordFlow"] == true

      OnlineMock.Keywords.Cookidoo.set_resource_owner_password_flow(false)
      conn = get(conn, ~p"/.well-known/home/LANG")
      meta = json_response(conn, 200)["meta"]

      assert meta["ResourceOwnerPasswordFlow"] == false
    end
  end
end
