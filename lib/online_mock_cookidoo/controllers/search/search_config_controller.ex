defmodule OnlineMockCookidoo.Search.SearchConfigController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, _params) do
    json(conn, %{})
  end
end
