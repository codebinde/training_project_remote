defmodule OnlineMockCookidoo.RecipeAssets.ModesController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMock.Data.ModesAndTools

  plug Plug.CheckDataAvailability,
    table: ModesAndTools.get_table(),
    path_generator: {ModesAndTools, :get_path, []}

  plug Plug.CacheControl,
    etag_generation:
      {OnlineMock.Data, :etag_for_connection,
       [&ModesAndTools.get_path/0, &ModesAndTools.get_table/0]}

  def index(conn, _params) do
    %{filename: filename, data: data} = :ets.lookup_element(:files_table, "modes.tar.gz", 2)
    send_download(conn, {:binary, data}, filename: filename)
  end
end
