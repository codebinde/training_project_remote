defmodule OnlineMockCookidoo.Search.SearchResultsController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, %{"query" => query}) do
    render(conn, :index, query: query)
  end
end
