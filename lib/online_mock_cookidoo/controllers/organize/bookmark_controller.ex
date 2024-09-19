defmodule OnlineMockCookidoo.Organize.BookmarkController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  require Logger

  alias OnlineMock.Data.Bookmarks

  plug Plug.CacheControl,
    etag_generation:
      {OnlineMock.Data, :etag_for_connection, [&Bookmarks.get_path/0, &Bookmarks.get_table/0]}

  def index(conn, _params) do
    render(conn, :index)
  end
end
