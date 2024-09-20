defmodule OnlineMockEST.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :online_mock

  plug Plug.LoggerMetadata, endpoint: "EST", scheme: "HTTPS"
  plug Plug.RequestId, http_header: "correlation-id"
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  if Mix.env() not in [:dev, :test] do
    plug Plug.CheckCookieEnforcement, endpoint: __MODULE__
    plug Plug.AccessTokenLogger, :expect_no_token
    plug Plug.CorrelationID
  end

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug OnlineMockEST.Router

  def init(_key, config) do
    config =
      if config[:https] do
        key = OnlineMock.PKI.lookup_key(:est, :der)
        {:Certificate, cert} = OnlineMock.PKI.lookup_cert(:est, :der)

        Keyword.update!(
          config,
          :https,
          &Keyword.merge(&1, key: key, cert: cert, cacerts: load_cacerts())
        )
      else
        config
      end

    {:ok, config}
  end

  defp load_cacerts() do
    for name <- [:vorwerk_issuing, :vorwerk_intermediate, :vorwerk_root] do
      {:Certificate, cacert} = OnlineMock.PKI.lookup_cert(name, :der)
      cacert
    end
  end
end
