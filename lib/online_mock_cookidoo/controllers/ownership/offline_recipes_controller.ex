defmodule OnlineMockCookidoo.Ownership.OfflineRecipesController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMock.Data.OwnershipList

  plug Plug.CacheControl,
    etag_generation:
      {OnlineMock.Data, :etag_for_connection,
       [&OwnershipList.get_path/0, &OwnershipList.get_table/0]}

  def index(conn, _params) do
    render(conn, :index)
  end
end
