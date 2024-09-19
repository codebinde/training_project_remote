import Config

config :online_mock, OnlineMockCloud.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4006],
  server: false

config :online_mock, OnlineMockCookidoo.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4007],
  server: false

config :online_mock, OnlineMockEST.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4008],
  server: false

config :online_mock, OnlineMockInfrastructure.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4009],
  server: false

config :online_mock, OnlineMockOCSP.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4010],
  server: false

config :online_mock, OnlineMockRobotRemote.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4011],
  server: false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
