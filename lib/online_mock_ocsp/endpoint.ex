defmodule OnlineMockOCSP.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :online_mock

  plug Plug.LoggerMetadata, endpoint: "OCSP", scheme: "HTTP"
  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  if Mix.env() not in [:dev, :test] do
    plug Plug.CheckCookieEnforcement, endpoint: __MODULE__
    plug Plug.AccessTokenLogger, :expect_no_token
  end

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Parsers,
    parsers: [OnlineMockOCSP.Parsers.Request],
    pass: ["application/ocsp-request"]

  plug Plug.MethodOverride
  plug Plug.Head
  plug OnlineMockOCSP.Router
end
