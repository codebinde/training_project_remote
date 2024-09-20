defmodule OnlineMockCookidoo.Recommender.OfflineRecipesController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, _params) do
    json(conn, %{"recipes" => []})
  end
end
