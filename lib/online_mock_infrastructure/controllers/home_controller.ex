defmodule OnlineMockInfrastructure.HomeController do
  @moduledoc false

  use OnlineMockInfrastructure, :controller

  plug :put_state, [:home_doc_response]
  plug :halt_on_error

  def show(conn, %{"country" => country}) do
    OnlineMock.log_event(:infrastructure_home_show, country)

    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "ts:time": %{href: url(~p"/time") <> "{?challenge}", templated: true},
        "ca:est-cacerts": %{
          href: url(OnlineMockEST.Endpoint, OnlineMockEST.Router, ~p"/.well-known/est/cacerts")
        },
        "ca:est-simpleenroll": %{
          href:
            url(OnlineMockEST.Endpoint, OnlineMockEST.Router, ~p"/.well-known/est/simpleenroll")
        },
        "ca:est-simplereenroll": %{
          href:
            url(OnlineMockEST.Endpoint, OnlineMockEST.Router, ~p"/.well-known/est/simplereenroll")
        }
      }
    })
  end

  defp put_state(conn, path) do
    state = OnlineMock.State.get(path)
    assign(conn, :state, state)
  end

  defp halt_on_error(conn, _opts) do
    case conn.assigns[:state] do
      :internal_server_error ->
        conn |> send_resp(:internal_server_error, "") |> halt()

      _ ->
        conn
    end
  end
end
