defmodule OnlineMockCookidoo.CustomerRecipes.RecipesListControllerTest do
  use OnlineMockCookidoo.ConnCase

  @tag :skip
  test "Unsetting status response returns url '/COUNTRY/customer-recipes/recipes-list'", %{
    conn: conn
  } do
    # GIVEN
    Plug.StatusResponder.unset_status_response(["COUNTRY", "customer-recipes", "recipes-list"])

    # WHEN
    conn = get(conn, "/COUNTRY/customer-recipes/recipes-list")

    # THEN
    assert html_response(conn, 200) =~ "CUSTOMER RECIPES"
  end
end
