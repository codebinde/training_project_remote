defmodule OnlineMockCookidoo.Organize.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "organize:api-managed-list": %{href: url(~p"/organize/managed-list")},
        "organize:api-custom-list": %{href: url(~p"/organize/custom-list")},
        "organize:api-custom-list-recipe": %{href: url(~p"/organize/custom-list")},
        "organize:api-bookmark": %{href: url(~p"/organize/bookmark")},
        "organize:api-cooking-history-multiple": %{
          href: url(~p"/organize/cooking-history-multiple")
        },
        "organize:api-list-sync": %{href: url(~p"/organize/list-sync")},
        "organize:api-list-sync-all": %{href: url(~p"/organize/list-sync")},
        "organize:api-associated-recipe-list": %{href: url(~p"/organize/associated-recipe-list")}
      }
    })
  end
end
