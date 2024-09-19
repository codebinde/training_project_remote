defmodule OnlineMockCookidoo.Organize.ManagedListController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, %{"id" => id}) do
    case Enum.find(OnlineMock.State.get([:managedlists]), fn map ->
           map["collectionId"] == id
         end) do
      nil -> send_resp(conn, :not_found, "")
      _ -> render(conn, :show, id: id)
    end
  end

  def index(conn, %{"page" => _page}) do
    render(conn, :index)
  end

  def index(conn, _params) do
    render(conn, :index)
  end

  def create(conn, _params) do
    render(conn, :index)
  end
end
