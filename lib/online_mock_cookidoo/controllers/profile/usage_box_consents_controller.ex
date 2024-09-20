defmodule OnlineMockCookidoo.Profile.UsageBoxConsentsController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    send_resp(conn, :not_implemented, "")
  end
end
