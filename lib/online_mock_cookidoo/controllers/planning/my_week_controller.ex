defmodule OnlineMockCookidoo.Planning.MyWeekController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  import OnlineMockCookidoo.Planning.Common

  alias OnlineMock.Data.{PlannedRecipes, Etag}

  plug Plug.CacheControl,
    etag_generation: {__MODULE__, :etag_for_my_week, []}

  def index(conn, _params) do
    conn
    |> show(%{"id" => default_day_id()})
  end

  def show(conn, %{"id" => id}) do
    render(conn, :show, id: id)
  end

  def etag_for_my_week(%{"id" => id}) do
    PlannedRecipes.get_etags_for_recipes_after(id)
    |> Enum.map(fn [_, etag] -> etag end)
    |> Enum.sort(:asc)
    |> Etag.create_etag()
  end

  def etag_for_my_week(_) do
    etag_for_my_week(%{"id" => default_day_id()})
  end
end
