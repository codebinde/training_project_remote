defmodule OnlineMockCookidoo.Organize.BookmarkJSON do
  @moduledoc false
  alias OnlineMock.Data.Bookmarks

  def index(_assigns) do
    bookmarks =
      OnlineMock.Data.lookup_data(&Bookmarks.get_table/0, Bookmarks.get_path(), [])

    %{
      "bookmarks" => bookmarks,
      "page" => %{
        "page" => 0,
        "totalPages" => 1,
        "totalElements" => length(bookmarks)
      }
    }
  end
end
