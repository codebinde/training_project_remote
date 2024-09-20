defmodule OnlineMockCookidoo.RecipeAssets.RecipeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMockCookidoo.EncryptedDataLink
  alias OnlineMock.Data.Encrypted.Recipe

  plug Plug.CacheControl,
       [
         etag_generation:
           {OnlineMock.Data, :etag_for_connection, [&Recipe.path_for_id/1, &Recipe.get_table/0]}
       ]
       when action == :show

  def show(conn, %{"id" => id}) do
    OnlineMock.log_event(:recipe_request, id)
    OnlineMock.LockHandle.await_unlock({:recipe, id})
    lookup_recipe_and_send_resp(conn, id)
  end

  def edit(conn, %{"id" => id} = _params) do
    if OnlineMock.State.get([:enc_recipe_download_available]) do
      path = Recipe.path_for_id(id)
      %{data: data} = :ets.lookup_element(Recipe.get_table(), path, 2)
      send_download(conn, {:binary, data}, filename: Path.basename(path))
    else
      send_resp(conn, :not_found, "")
    end
  end

  defp lookup_recipe_and_send_resp(conn, id) do
    path = Recipe.path_for_id(id)

    if :ets.member(Recipe.get_table(), path) do
      %{authTag: tag} = :ets.lookup_element(Recipe.get_table(), path, 2)
      href = url(~p"/recipe-assets/recipes/#{id}/edit")
      data = EncryptedDataLink.create_descriptor("recipe", href, tag)
      json(conn, data)
    else
      send_resp(conn, :not_found, "Recipe not found: id=#{id}")
    end
  end
end
