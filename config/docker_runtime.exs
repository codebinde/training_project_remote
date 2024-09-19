import Config

config :online_mock, OnlineMockCloud.Endpoint,
  https: [
    cipher_suite: :compatible,
    send_timeout: :infinity,
    protocol_options: [
      idle_timeout: :infinity,
      inactivity_timeout: :infinity,
      request_timeout: :infinity
    ],
    transport_options: [
      handshake_timeout: :infinity
    ],
    port: 4000
  ],
  http: false,
  url: [host: System.fetch_env!("ONLINE_MOCK_CLOUD")],
  server: true

config :online_mock, OnlineMockCookidoo.Endpoint,
  https: [
    cipher_suite: :compatible,
    verify: :verify_peer,
    fail_if_no_peer_cert: false,
    send_timeout: :infinity,
    protocol_options: [
      idle_timeout: :infinity,
      inactivity_timeout: :infinity,
      request_timeout: :infinity
    ],
    transport_options: [handshake_timeout: :infinity],
    port: 4001
  ],
  http: false,
  url: [host: System.fetch_env!("ONLINE_MOCK_COOKIDOO")],
  server: true

config :online_mock, OnlineMockEST.Endpoint,
  https: [
    cipher_suite: :compatible,
    send_timeout: :infinity,
    protocol_options: [
      idle_timeout: :infinity,
      inactivity_timeout: :infinity,
      request_timeout: :infinity
    ],
    transport_options: [
      handshake_timeout: :infinity
    ],
    port: 4002
  ],
  http: false,
  url: [host: System.fetch_env!("ONLINE_MOCK_CLOUD")],
  server: true

config :online_mock, OnlineMockInfrastructure.Endpoint,
  http: [
    send_timeout: :infinity,
    protocol_options: [
      idle_timeout: :infinity,
      inactivity_timeout: :infinity,
      request_timeout: :infinity
    ],
    transport_options: [
      handshake_timeout: :infinity
    ],
    port: 4003
  ],
  url: [host: System.fetch_env!("ONLINE_MOCK_CLOUD")],
  server: true

config :online_mock, OnlineMockOCSP.Endpoint,
  http: [
    send_timeout: :infinity,
    protocol_options: [
      idle_timeout: :infinity,
      inactivity_timeout: :infinity,
      request_timeout: :infinity
    ],
    transport_options: [
      handshake_timeout: :infinity
    ],
    port: 4004
  ],
  url: [host: System.fetch_env!("ONLINE_MOCK_CLOUD")],
  server: true

config :online_mock, OnlineMockRobotRemote.Endpoint,
  http: [
    send_timeout: :infinity,
    protocol_options: [
      idle_timeout: :infinity,
      inactivity_timeout: :infinity,
      request_timeout: :infinity
    ],
    transport_options: [
      handshake_timeout: :infinity
    ],
    port: 4005,
    ip: {0, 0, 0, 0}
  ],
  server: true

config :logger, truncate: :infinity

config :logger, :console,
  format: "\n$date $time [$level] $metadata\n$message\n",
  metadata: [:endpoint, :scheme, :request_id]
