defmodule OnlineMockCookidoo.Organize.CustomListController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, %{"id" => id}) do
    render(conn, :show, id: id)
  end

  def index(conn, _params) do
    render(conn, :index)
  end

  def create(conn, _params) do
    render(conn, :index)
  end
end
