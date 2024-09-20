defmodule OnlineMockInfrastructure.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :online_mock

  plug Plug.LoggerMetadata, endpoint: "Infrastructure", scheme: "HTTP"
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
  plug OnlineMockInfrastructure.Router
end
