defmodule OnlineMockCookidoo.StolenDevices.StatusControllerTest do
  use OnlineMockCookidoo.ConnCase

  test "GET /stolen-devices/status", %{conn: conn} do
    conn = get(conn, ~p"/stolen-devices/status")
    body = json_response(conn, 200)
    assert map_size(body) == 1
    assert body["blocked"] == false

    OnlineMock.Keywords.Cookidoo.StolenDevices.block_device("REASON")
    conn = get(conn, ~p"/stolen-devices/status")
    body = json_response(conn, 200)
    assert map_size(body) == 3
    assert body["blocked"] == true
    assert body["reason"] == "REASON"
    assert body["created"] =~ ~r/\d{4}-\d{2}-\d{2} \d{6}$/

    OnlineMock.Keywords.Cookidoo.StolenDevices.unblock_device()
    conn = get(conn, ~p"/stolen-devices/status")
    body = json_response(conn, 200)
    assert map_size(body) == 1
    assert body["blocked"] == false

    OnlineMock.Keywords.Cookidoo.StolenDevices.error(404)
    conn = get(conn, ~p"/stolen-devices/status")
    assert json_response(conn, 404) =~ "Not Found"
  end
end
