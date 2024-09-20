defmodule OnlineMockCookidoo.Planning.PlannerControllerTest do
  use OnlineMockCookidoo.ConnCase

  @tag :skip
  test "GET /COUNTRY/planning/planner", %{conn: conn} do
    conn = get(conn, "/COUNTRY/planning/planner")
    assert html_response(conn, 200) =~ "PLANNER"
  end
end
