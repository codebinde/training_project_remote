import Config

config :online_mock, OnlineMockCloud.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/online_mock_cloud/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :online_mock, OnlineMockCookidoo.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4001],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/online_mock_cookidoo/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :online_mock, OnlineMockEST.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/online_mock_est/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :online_mock, OnlineMockInfrastructure.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4003],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/online_mock_infrastructure/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :online_mock, OnlineMockOCSP.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4004],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/online_mock_ocsp/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :online_mock, OnlineMockRobotRemote.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4005],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  watchers: [],
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"lib/online_mock_robot_remote/(controllers|live|components)/.*(ex|heex)$"
    ]
  ]

config :online_mock, dev_routes: true

config :logger, truncate: :infinity
config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20
config :phoenix, :plug_init_mode, :runtime
