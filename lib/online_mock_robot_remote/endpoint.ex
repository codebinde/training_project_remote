defmodule OnlineMockRobotRemote.Endpoint do
  @moduledoc false

  use Phoenix.Endpoint, otp_app: :online_mock

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint], log: false
  plug Plug.Parsers, parsers: [RemoteLibrary.Parser]
  plug Plug.MethodOverride
  plug Plug.Head
  plug OnlineMockRobotRemote.Router
end
