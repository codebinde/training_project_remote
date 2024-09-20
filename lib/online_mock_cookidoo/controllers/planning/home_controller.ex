defmodule OnlineMockCookidoo.Planning.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "planning:web-my-week": %{href: url(~p"/planning/planner")},
        "planning:api-my-week": %{href: url(~p"/planning/my-week")},
        "planning:api-my-day": %{href: url(~p"/planning/my-day")},
        "planning:api-my-day-recipes": %{
          href: url(~p"/planning/my-day/planned-recipes?my_day_id={dayKey}&id={recipeId}"),
          templated: true
        },
        "planning:api-my-day-move-recipe": %{href: url(~p"/planning/my-day/move-recipe")},
        "planning:api-associated-recipe-list": %{href: url(~p"/planning/associated-recipe-list")}
      }
    })
  end
end
