defmodule Plug.StatusResponderTest do
  use OnlineMockCookidoo.ConnCase

  test "Setting status response to 500 returns internal server error", %{conn: conn} do
    # GIVEN
    Plug.StatusResponder.set_status_response(
      ["COUNTRY", "customer-recipes", "recipes-list"],
      500,
      "internal server error"
    )

    # WHEN
    conn = get(conn, "/COUNTRY/customer-recipes/recipes-list")

    # THEN
    assert response(conn, 500) == "internal server error"
    Plug.StatusResponder.unset_status_response(["COUNTRY", "customer-recipes", "recipes-list"])
  end

  test "Setting status response to 404 returns not found", %{conn: conn} do
    # GIVEN
    Plug.StatusResponder.set_status_response(
      ["COUNTRY", "customer-recipes", "recipes-list"],
      404,
      "not found"
    )

    # WHEN
    conn = get(conn, "/COUNTRY/customer-recipes/recipes-list")

    # THEN
    assert response(conn, 404) == "not found"
    Plug.StatusResponder.unset_status_response(["COUNTRY", "customer-recipes", "recipes-list"])
  end
end
