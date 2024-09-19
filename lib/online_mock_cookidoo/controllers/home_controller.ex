defmodule OnlineMockCookidoo.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__
  plug :firmware_home_delay
  plug :remove_links

  def show(conn, _params) do
    links =
      %{
        self: %{href: current_url(conn)},
        "tmde2:auth": %{href: url(~p"/auth/.well-known/home")},
        "tmde2:cadd": %{href: url(~p"/cadd/.well-known/home")},
        "tmde2:customer-devices": %{href: url(~p"/customer-devices/.well-known/home")},
        "tmde2:commerce": %{href: url(~p"/commerce/.well-known/home")},
        "tmde2:customer-recipes": %{href: url(~p"/customer-recipes/.well-known/home")},
        "tmde2:firmware": %{href: url(~p"/firmware/.well-known/home")},
        "tmde2:foundation": %{href: url(~p"/foundation/.well-known/home")},
        "tmde2:notifications": %{href: url(~p"/notifications/.well-known/home")},
        "tmde2:organize": %{href: url(~p"/organize/.well-known/home")},
        "tmde2:ownership": %{href: url(~p"/ownership/.well-known/home")},
        "tmde2:planning": %{href: url(~p"/planning/.well-known/home")},
        "tmde2:profile": %{href: url(~p"/profile/.well-known/home")},
        "tmde2:recipe-assets": %{href: url(~p"/recipe-assets/.well-known/home")},
        "tmde2:recipe-details": %{href: url(~p"/recipe-details/.well-known/home")},
        "tmde2:recommender": %{href: url(~p"/recommender/.well-known/home")},
        "tmde2:search": %{href: url(~p"/search/.well-known/home")},
        "tmde2:stolen-devices": %{href: url(~p"/stolen-devices/.well-known/home")},
        "tmde2:usagebox": %{href: url(~p"/usagebox/.well-known/home")}
      }
      |> Map.drop(conn.assigns[:removed_links])

    resource_owner_password_flow =
      OnlineMock.State.get([:resource_owner_password_credential_flow], true)

    meta = %{ResourceOwnerPasswordFlow: resource_owner_password_flow}

    json(conn, %{_links: links, meta: meta})
  end

  defp firmware_home_delay(conn, _opts) do
    if delay = OnlineMock.State.get([:firmware_home_delay]), do: Process.sleep(delay)
    conn
  end

  defp remove_links(conn, _opts) do
    removed_links = OnlineMock.RootHomeLinks.list_removed_links()
    assign(conn, :removed_links, removed_links)
  end
end
