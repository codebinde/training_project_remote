defmodule OnlineMockCookidoo.RecipeDetails.RecipeVariantsController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, %{"id" => id}) do
    if :ets.member(:recipe_variants, id) do
      variants = :ets.lookup_element(:recipe_variants, id, 2)
      json(conn, variants)
    else
      send_resp(conn, :not_found, "Recipe Variant not found: id=#{id}")
    end
  end
end
