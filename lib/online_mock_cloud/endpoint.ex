defmodule OnlineMockCloud.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :online_mock

  @session_options [
    store: :cookie,
    key: "_online_mock_cloud_key",
    signing_salt: "hd0BF88q",
    same_site: "Lax"
  ]

  plug Plug.LoggerMetadata, endpoint: "Cloud", scheme: "HTTPS"
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  if Mix.env() not in [:dev, :test] do
    plug Plug.CheckCookieEnforcement, endpoint: __MODULE__
    plug Plug.AccessTokenLogger, :expect_no_token
  end

  plug Plug.State,
    filter: &__MODULE__.stream_delay_filter/1,
    callback: &__MODULE__.stream_delay_callback/3

  plug Plug.State,
    filter: &__MODULE__.stream_segment_filter/1,
    callback: &__MODULE__.stream_segment_callback/3

  plug Plug.Static,
    at: "/",
    from: :online_mock,
    gzip: false,
    only: OnlineMockCloud.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug OnlineMockCloud.Router

  def init(_key, config) do
    config =
      if config[:https] do
        key = OnlineMock.PKI.lookup_key(:world_cloud, :der)
        {:Certificate, cert} = OnlineMock.PKI.lookup_cert(:world_cloud, :der)
        Keyword.update!(config, :https, &Keyword.merge(&1, key: key, cert: cert))
      else
        config
      end

    {:ok, config}
  end

  def stream_delay_filter(%{method: "GET", path_info: ["stream", _, _]}) do
    [:video_stream, :delay]
  end

  def stream_delay_filter(_) do
  end

  def stream_delay_callback(conn, delay, _path) do
    Process.sleep(delay)
    conn
  end

  def stream_segment_filter(%{method: "GET", path_info: ["stream", _, file]}) do
    case Path.extname(file) do
      ".m4s" ->
        [_prefix, segment, _suffix] = String.split(file, "_")
        segment = String.to_integer(segment)
        [:video_stream, :segments, segment]

      _ ->
        nil
    end
  end

  def stream_segment_filter(_) do
  end

  def stream_segment_callback(conn, :not_found, _path) do
    conn |> send_resp(:not_found, "") |> halt()
  end

  def stream_segment_callback(conn, :internal_server_error, _path) do
    conn |> send_resp(:internal_server_error, "") |> halt()
  end

  def stream_segment_callback(conn, %{:delayed => delay_time}, _path) do
    Process.sleep(delay_time)
    conn
  end

  def stream_segment_callback(conn, _, [_, _, segment]) do
    OnlineMock.LockHandle.await_unlock({:video_stream_segment, segment})
    OnlineMock.make_video_stream_segment_available(segment)
    conn
  end
end
