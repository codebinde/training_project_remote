defmodule OnlineMockCookidoo.Planning.PlannedRecipesController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  alias OnlineMock.Data.PlannedRecipes

  def index(conn, %{"my_day_id" => my_day_id}) do
    render(conn, :index, my_day_id: my_day_id)
  end

  def delete(conn, %{"my_day_id" => my_day_id, "id" => id}) do
    PlannedRecipes.remove(my_day_id, id)
    render(conn, :delete, my_day_id: my_day_id, id: id)
  end
end
