defmodule OnlineMockCookidoo.Commerce.AvailableSubscriptionsController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _) do
    # Link can be dead for now
    send_resp(conn, :not_implemented, "Not implemented")
  end
end
