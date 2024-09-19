defmodule OnlineMockCookidoo.RecipeAssets.PrimaryCategoriesController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, _params) do
    import Plug.Conn.Status
    reason = :not_found

    conn
    |> put_status(reason)
    |> json(reason |> code() |> reason_phrase())
  end
end
