defmodule OnlineMockCookidoo do
  @moduledoc false

  def static_paths, do: ~w(assets cheatsheet favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router

      import OnlineMockCookidoo, only: [reject_client_cert: 2]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller,
        formats: [:html, :json, "rhd-device": "JSON", "json-hal": "JSON"],
        layouts: [html: OnlineMockCookidoo.Layouts]

      import Plug.Conn

      unquote(verified_routes())

      import OnlineMockCookidoo, only: [invalid_client_cert: 2]
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {OnlineMockCookidoo.Layouts, :app}

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      import Phoenix.HTML

      alias Phoenix.LiveView.JS

      unquote(verified_routes())
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: OnlineMockCookidoo.Endpoint,
        router: OnlineMockCookidoo.Router,
        statics: OnlineMockCookidoo.static_paths()
    end
  end

  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end

  def invalid_client_cert(conn, module) do
    if OnlineMock.State.get([:invalid_client_cert, module]) do
      conn
      |> Plug.Conn.send_resp(:ssl_certificate_error, "")
      |> Plug.Conn.halt()
    else
      conn
    end
  end

  def reject_client_cert(conn, _opts) do
    if OnlineMock.State.get([:reject_client_cert, conn.path_info]) do
      conn
      |> Plug.Conn.send_resp(:ssl_certificate_error, "")
      |> Plug.Conn.halt()
    else
      conn
    end
  end
end
