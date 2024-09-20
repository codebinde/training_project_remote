defmodule OnlineMockCookidoo.Auth.SessionController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def new(conn, _params) do
    render(conn, :new)
  end

  def create(conn, %{"session" => %{"username" => _user, "password" => _pass}}) do
    return_to = get_session(conn, :return_to)

    conn
    |> renew_session()
    |> put_session(:authenticated, true)
    |> redirect(to: return_to)
  end

  defp renew_session(conn) do
    conn
    |> configure_session(renew: true)
    |> clear_session()
  end
end
