defmodule OnlineMockCookidoo.Planning.MyDayController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  import OnlineMockCookidoo.Planning.Common

  alias OnlineMock.Data.PlannedRecipes

  @allowed_sources ~w(VORWERK CUSTOMER)
  @default_locale "en"

  plug Plug.CacheControl,
    etag_generation: {
      OnlineMock.Data,
      :etag_for_connection,
      [&PlannedRecipes.get_path_for_id/1, &PlannedRecipes.get_table/0]
    }

  def index(conn, _params) do
    conn
    |> show(%{"id" => default_day_id()})
  end

  def show(conn, %{"id" => id}) do
    render(conn, :show, id: id)
  end

  def delete(conn, %{"id" => id}) do
    PlannedRecipes.remove_all(id)
    render(conn, :delete, id: id)
  end

  def update(conn, %{"id" => id, "recipeSource" => recipe_source} = params)
      when recipe_source in @allowed_sources do
    conn
    |> put_created_if_new(id)
    |> do_update(id, Map.get(params, "recipeIds"))
    |> render(:update, id: id)
  end

  def put_created_if_new(conn, day_id) do
    if PlannedRecipes.recipes_planned_for_day?(day_id) do
      conn
    else
      put_status(conn, :created)
    end
  end

  def do_update(conn, day_id, recipe_ids) do
    for recipe_id <- recipe_ids do
      PlannedRecipes.append(day_id, recipe_id, @default_locale)
    end

    new_etag =
      OnlineMock.Data.retrieve_etag(
        PlannedRecipes.get_path_for_id(day_id),
        PlannedRecipes.get_table()
      )

    put_resp_header(conn, "etag", new_etag)
  end
end
