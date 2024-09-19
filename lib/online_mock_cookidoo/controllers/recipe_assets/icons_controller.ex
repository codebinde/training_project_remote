defmodule OnlineMockCookidoo.RecipeAssets.IconsController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    import Plug.Conn.Status
    reason = :not_found

    conn
    |> put_status(reason)
    |> json(reason |> code() |> reason_phrase())
  end
end
