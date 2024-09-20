defmodule OnlineMockCookidoo.Usagebox.UploadURLJSON do
  @moduledoc false

  use OnlineMockCookidoo, :verified_routes

  def show(_assigns) do
    %{"url" => url(~p"/usagebox/upload"), "expTime" => 0}
  end
end
