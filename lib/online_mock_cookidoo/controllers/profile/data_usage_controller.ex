defmodule OnlineMockCookidoo.Profile.DataUsageController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
