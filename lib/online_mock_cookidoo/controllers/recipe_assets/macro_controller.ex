defmodule OnlineMockCookidoo.RecipeAssets.MacroController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMockCookidoo.EncryptedDataLink
  alias OnlineMock.Data.Encrypted.Macro

  plug Plug.CacheControl,
       [
         etag_generation:
           {OnlineMock.Data, :etag_for_connection, [&Macro.path_for_id/1, &Macro.get_table/0]}
       ]
       when action == :show

  def show(conn, %{"id" => id}) do
    path = Macro.path_for_id(id)

    if :ets.member(Macro.get_table(), path) do
      %{authTag: tag} = :ets.lookup_element(Macro.get_table(), path, 2)
      href = url(~p"/recipe-assets/macros/#{id}/edit")
      data = EncryptedDataLink.create_descriptor("macro", href, tag)
      json(conn, data)
    else
      send_resp(conn, :not_found, "Macro #{id} not available")
    end
  end

  def edit(conn, %{"id" => id} = _params) do
    path = Macro.path_for_id(id)

    if :ets.member(Macro.get_table(), path) do
      %{data: data} = :ets.lookup_element(Macro.get_table(), path, 2)
      send_download(conn, {:binary, data}, filename: Path.basename(path))
    else
      send_resp(conn, :not_found, "File #{id}.enc not available")
    end
  end
end
