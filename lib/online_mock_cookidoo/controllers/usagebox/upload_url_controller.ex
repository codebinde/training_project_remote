defmodule OnlineMockCookidoo.Usagebox.UploadURLController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    render(conn, :show)
  end
end
