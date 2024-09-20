defmodule OnlineMockCookidoo.StolenDevices.HomeControllerTest do
  use OnlineMockCookidoo.ConnCase

  test "GET /stolen-devices/.well-known/home", %{conn: conn} do
    conn = get(conn, ~p"/stolen-devices/.well-known/home")

    assert json_response(conn, 200)["_links"]["stolen-devices:status"]["href"] ==
             url(~p"/stolen-devices/status")
  end
end
