defmodule OnlineMockCookidoo.Firmware.UpdateController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug Plug.EventLog, event: :firmware_update, conn_keys: [:query_params]
  plug :invalid_client_cert, __MODULE__
  plug :sleep, [:firmware_update_delay]
  plug :put_state, [:update_available]
  plug :check_update_available

  def show(conn, %{"version" => version}) do
    update_version = conn.assigns[:state]

    json(conn, %{
      flags: flags(),
      version: update_version,
      _links: %{self: %{href: current_url(conn, %{version: version})}},
      _embedded: %{fragments: fragments(update_version)}
    })
  end

  defp flags do
    %{
      onboarding: OnlineMock.State.get([:firmware_update_onboarding], false),
      enforce: OnlineMock.State.get([:firmware_update_enforce], false)
    }
  end

  defp fragments(sw_version) do
    filter = OnlineMock.State.get([:firmware_update_fragments_filter], fn _ -> true end)

    for {name, %{path: path, algorithm: algorithm, key: key, ivec: ivec, tag: tag}} = item <-
          :ets.lookup_element(:sw_image_table, sw_version, 2),
        filter.(item) do
      %{
        name: name,
        algorithm: algorithm,
        key: Base.encode64(key),
        iv: Base.encode64(ivec),
        authTag: Base.encode64(tag),
        _links: %{download: %{href: url(~p"/firmware/#{path}")}}
      }
    end
  end

  defp sleep(conn, path) do
    if delay = OnlineMock.State.get(path), do: Process.sleep(delay)
    conn
  end

  defp put_state(conn, path) do
    state = OnlineMock.State.get(path)
    assign(conn, :state, state)
  end

  defp check_update_available(conn, _opts) do
    case conn.assigns[:state] do
      nil ->
        conn |> send_resp(:no_content, "") |> halt()

      _ ->
        conn
    end
  end
end
