defmodule OnlineMockCookidoo.CustomerRecipes.CustomerRecipeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMock.Data.CustomerRecipe

  plug Plug.CacheControl,
    etag_generation:
      {OnlineMock.Data, :etag_for_connection,
       [&CustomerRecipe.path_for_id/1, &CustomerRecipe.get_table/0]}

  def show(conn, %{"id" => id}) do
    OnlineMock.log_event(:customer_recipe_request, id)
    OnlineMock.LockHandle.await_unlock({:customer_recipe, id})
    lookup_recipe_and_send_resp(conn, id)
  end

  defp lookup_recipe_and_send_resp(conn, id) do
    case CustomerRecipe.get(id) do
      nil ->
        send_resp(conn, :not_found, "Customer recipe not found: id=#{id}")

      recipe ->
        conn
        |> put_resp_content_type("application/json")
        |> send_resp(:ok, recipe)
    end
  end
end
