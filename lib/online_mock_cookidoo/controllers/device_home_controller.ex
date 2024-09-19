defmodule OnlineMockCookidoo.DeviceHomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, %{"country" => country}) do
    conn
    |> put_status(:temporary_redirect)
    |> redirect(external: url(~p"/.well-known/home/#{country}"))
  end
end
