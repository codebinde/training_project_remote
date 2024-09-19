defmodule OnlineMockCookidoo.Organize.CookingHistoryMultipleController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  require Logger

  def create(conn, _params) do
    send_resp(conn, :ok, "")
  end
end
