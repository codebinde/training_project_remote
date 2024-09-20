import Config

import_config "pki.exs"
import_config "auth.exs"

config :online_mock, OnlineMockCloud.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: OnlineMockCloud.ErrorHTML, json: OnlineMockCloud.ErrorJSON],
    layout: false
  ],
  secret_key_base: "cXNV9adHto80uiq7+1jPj8HOK9meoCl1iH3ettC0yO3XorwPUjzPxEf2lzkkUZgO"

config :online_mock, OnlineMockCookidoo.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: OnlineMockCookidoo.ErrorHTML, json: OnlineMockCookidoo.ErrorJSON],
    layout: false
  ],
  secret_key_base: "cXNV9adHto80uiq7+1jPj8HOK9meoCl1iH3ettC0yO3XorwPUjzPxEf2lzkkUZgO"

config :online_mock, OnlineMockEST.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: OnlineMockEST.ErrorHTML, json: OnlineMockEST.ErrorJSON],
    layout: false
  ],
  secret_key_base: "IZ0U4G/VhxYopQm9irMFnY5YAClUPDOSw66OqJu+vRcBa7DG94MlRdPIXjzc6v6X"

config :online_mock, OnlineMockInfrastructure.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [json: OnlineMockInfrastructure.ErrorJSON],
    layout: false
  ],
  secret_key_base: "19Xu3lvhHkoSVRofsygPpOGWq4RYA7lXbwKlbfNCBa077c05zi8W1KqT9BQ4b+I7"

config :online_mock, OnlineMockOCSP.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: OnlineMockOCSP.ErrorHTML, json: OnlineMockOCSP.ErrorJSON],
    layout: false
  ],
  secret_key_base: "qfAX9u0icDPLv/e8HPeiEQd9IYI+cE2M46BcZf9pHQR47Hp06EABH5UhrjzXtegy"

config :online_mock, OnlineMockRobotRemote.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: OnlineMockRobotRemote.ErrorHTML, json: OnlineMockRobotRemote.ErrorJSON],
    layout: false
  ],
  secret_key_base: "Xwpr2is/a6PnEU2mE99D6kvUk3JI7Fa4+2OLBIr+gKw9GPrFtdPFG5XFXEAV0kQh"

config :phoenix, :json_library, Jason

config :mime, :types, %{
  "application/hal+json" => ["json-hal"],
  "application/vnd.vorwerk.tmde2.rhd.device.hal+json" => ["rhd-device"],
  "application/ocsp-response" => ["ors"]
}

config :phoenix_template, :format_encoders, "json-hal": Jason

config :plug, :statuses, %{
  495 => "SSL Certificate Error"
}

config :online_mock,
  timeout_keyword_wait: 120_000

config :online_mock,
  enc_ivec: <<1::size(96)>>,
  enc_key: <<1::size(256)>>

# Import environment specific config. This must remain at the bottom of this file so it overrides
# the configuration defined above.
import_config "#{config_env()}.exs"
