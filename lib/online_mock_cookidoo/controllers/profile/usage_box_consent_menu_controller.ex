defmodule OnlineMockCookidoo.Profile.UsageBoxConsentMenuController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def index(conn, _params) do
    send_resp(conn, :not_implemented, "")
  end
end
