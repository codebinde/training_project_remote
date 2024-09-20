defmodule OnlineMockCookidoo.Commerce.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__
  plug :put_state, [OnlineMockCookidoo.Commerce, :missing_link]

  def show(conn, _params) do
    links =
      case conn.assigns[:state] do
        true ->
          %{}

        _ ->
          %{
            "commerce:available-subscriptions-via-web": %{
              href:
                url(~p"/lang/commerce/available-subscriptions")
                |> String.replace("lang", "{lang}"),
              templated: true
            }
          }
      end

    links = Map.merge(%{self: %{href: current_url(conn)}}, links)

    json(conn, %{_links: links})
  end

  defp put_state(conn, path) do
    state = OnlineMock.State.get(path)
    assign(conn, :state, state)
  end
end
