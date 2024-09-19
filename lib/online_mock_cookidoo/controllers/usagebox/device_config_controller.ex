defmodule OnlineMockCookidoo.Usagebox.DeviceConfigController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    render(conn, :show)
  end
end
