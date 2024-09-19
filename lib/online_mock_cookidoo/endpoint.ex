defmodule OnlineMockCookidoo.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :online_mock

  @session_options [
    store: :cookie,
    key: "_online_mock_key",
    signing_salt: "hd0BF88q",
    same_site: "Lax"
  ]

  import OnlineMock.Plugs, only: [delay: 2]

  plug Plug.LoggerMetadata, endpoint: "Cookidoo", scheme: "HTTPS"
  plug Plug.RequestId, http_header: "correlation-id"
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]
  plug CORSPlug, origin: [~r/com.*$/, ~r/https?.*$/]

  if Mix.env() not in [:dev, :test] do
    plug Plug.CorrelationID
    plug Plug.UserAgent, key: __MODULE__
    plug Plug.AccessTokenLogger, :expect_token
  end

  plug Plug.EventLog, event: OnlineMockCookidoo, conn_keys: [:method, :request_path]
  plug Plug.StatusResponder
  plug :delay, :cookidoo

  plug Plug.Static,
    at: "/",
    from: :online_mock,
    gzip: false,
    only: OnlineMockCookidoo.static_paths()

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
  plug OnlineMockCookidoo.Router

  def init(_key, config) do
    config =
      if config[:https] do
        key = OnlineMock.PKI.lookup_key(:cookidoo, :der)
        {:Certificate, cert} = OnlineMock.PKI.lookup_cert(:cookidoo, :der)
        reuse_session = &reuse_session/4

        Keyword.update!(
          config,
          :https,
          &Keyword.merge(&1,
            key: key,
            cert: cert,
            cacerts: cacerts(),
            reuse_session: reuse_session
          )
        )
      else
        config
      end

    {:ok, config}
  end

  defp cacerts() do
    for name <- [:vorwerk_issuing, :vorwerk_intermediate, :vorwerk_root] do
      {:Certificate, cacert} = OnlineMock.PKI.lookup_cert(name, :der)
      cacert
    end
  end

  defp reuse_session(_suggested_session_id, _peer_cert, _compression, _cipher_suite) do
    case OnlineMock.State.get([__MODULE__, :reuse_session]) do
      nil ->
        true

      value ->
        value
    end
  end
end
