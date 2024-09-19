defmodule OnlineMock.TestAutomationConfigProvider do
  @moduledoc """
  This module is a config provider for releases --such as `ci`-- that are supposed to run inside the
  test automation framework.

  ## Test Automation Configuration

  The following configuration keys are set using the configuration of the test automation framework.

  ### Application `online_mock`

    * `OnlineMockCloud.Endpoint`
        * `url`
            * `host` - Set to the concatenation of `ONLINE_MOCK_HOSTNAME` and `".cloud"`
        * `https`
            * `port` - Set to the sum of `SERVICE_PORT_BASE` and `ONLINE_MOCK_PORT_OFFSET.cloud`

    * `OnlineMockCookidoo.Endpoint`
        * `url`
            * `host` - Set to the concatenation of `ONLINE_MOCK_HOSTNAME` and `".cookidoo"`
        * `https`
            * `port` - Set to the sum of `SERVICE_PORT_BASE` and `ONLINE_MOCK_PORT_OFFSET.cookidoo`

    * `OnlineMockEST.Endpoint`
        * `url`
            * `host` - Set to the concatenation of `ONLINE_MOCK_HOSTNAME` and `".cloud"`
        * `https`
            * `port` - Set to the sum of `SERVICE_PORT_BASE` and `ONLINE_MOCK_PORT_OFFSET.est`

    * `OnlineMockInfrastructure.Endpoint`
        * `url`
            * `host` - Set to the concatenation of `ONLINE_MOCK_HOSTNAME` and `".cloud"`
        * `http`
            * `port` - Set to the sum of `SERVICE_PORT_BASE` and
            `ONLINE_MOCK_PORT_OFFSET.infrastructure`

    * `OnlineMockRobotRemote.Endpoint`
        * `http`
            * `port` - Set to the sum of `SERVICE_PORT_BASE` and
            `REMOTE_LIB_PORT_OFFSET.online_mock`

    * Each endpoint can be configured to require or prohibit certain cookies.
      The enforced or prohibited cookies have to be specified as key value pairs in
      `ONLINEMOCK_COOKIE_ENFORCEMENT_RULES.<ENDPOINT>.<RULE>`
      where `<ENDPOINT>` is the endpoint the rules are specified for
      (one of `cookidoo`, `infrastructure`, `ocsp`, `est`, `cloud`),
      and <RULE> is one of `require`, `prohibit`.
      Unmentioned endpoints are unaffected.

      Example configuration:
      ```
      ONLINEMOCK_COOKIE_ENFORCEMENT_RULES:
        cookidoo:
          require:
            key: value
            access: granted
        est:
          require:
            key: value
            access: granted
          prohibit:
            age: 24
            secret: abcdef
        cloud:
          prohibit:
            access: denied
      ```

  ### Application `logger`

    * `level` - Set to the value of `online_mock_log_level`
  """

  @behaviour Config.Provider

  @domain_cookidoo ".cookidoo"
  @domain_cloud ".cloud"
  @cloud_key "cloud"
  @cookidoo_key "cookidoo"
  @est_key "est"
  @infrastructure_key "infrastructure"
  @ocsp_key "ocsp"

  @impl true
  def init(opts), do: opts

  @impl true
  def load(config, _opts) do
    {:ok, _} = Application.ensure_all_started(:test_automation_framework)
    ta_config = TestAutomationFramework.read_config()

    config
    |> configure_cloud(ta_config)
    |> configure_cookidoo(ta_config)
    |> configure_est(ta_config)
    |> configure_infrastructure(ta_config)
    |> configure_ocsp(ta_config)
    |> configure_robot_remote(ta_config)
    |> configure_website_inflation(ta_config)
    |> configure_log_level(ta_config)
  end

  defp configure_cloud(config, ta_config) do
    config
    |> configure_port(ta_config, OnlineMockCloud.Endpoint, @cloud_key, :https)
    |> configure_host(ta_config, OnlineMockCloud.Endpoint)
    |> configure_cookie_enforcement(ta_config, OnlineMockCloud.Endpoint, @cloud_key)
  end

  defp configure_cookidoo(config, ta_config) do
    config
    |> configure_port(ta_config, OnlineMockCookidoo.Endpoint, @cookidoo_key, :https)
    |> configure_host(ta_config, OnlineMockCookidoo.Endpoint, @domain_cookidoo)
    |> configure_cookie_enforcement(ta_config, OnlineMockCookidoo.Endpoint, @cookidoo_key)
  end

  defp configure_est(config, ta_config) do
    config
    |> configure_port(ta_config, OnlineMockEST.Endpoint, @est_key, :https)
    |> configure_host(ta_config, OnlineMockEST.Endpoint, @domain_cookidoo)
    |> configure_cookie_enforcement(ta_config, OnlineMockEST.Endpoint, @est_key)
  end

  defp configure_infrastructure(config, ta_config) do
    config
    |> configure_port(ta_config, OnlineMockInfrastructure.Endpoint, @infrastructure_key, :http)
    |> configure_host(ta_config, OnlineMockInfrastructure.Endpoint, @domain_cookidoo)
    |> configure_cookie_enforcement(
      ta_config,
      OnlineMockInfrastructure.Endpoint,
      @infrastructure_key
    )
  end

  defp configure_ocsp(config, ta_config) do
    config
    |> configure_port(ta_config, OnlineMockOCSP.Endpoint, "ocsp", :http)
    |> configure_host(ta_config, OnlineMockOCSP.Endpoint, @domain_cookidoo)
    |> configure_cookie_enforcement(ta_config, OnlineMockOCSP.Endpoint, @ocsp_key)
  end

  defp configure_robot_remote(config, ta_config) do
    configure_port(
      config,
      ta_config,
      OnlineMockRobotRemote.Endpoint,
      "REMOTE_LIB_PORT_OFFSET",
      "online_mock",
      :http
    )
  end

  defp configure_port(
         config,
         ta_config,
         endpoint,
         key_offsets \\ "ONLINE_MOCK_PORT_OFFSET",
         key,
         scheme
       ) do
    base = Map.fetch!(ta_config, "SERVICE_PORT_BASE")
    offsets = Map.fetch!(ta_config, key_offsets)
    offset = Map.fetch!(offsets, key)
    Config.Reader.merge(config, online_mock: [{endpoint, [{scheme, [port: base + offset]}]}])
  end

  defp configure_host(config, ta_config, endpoint, domain \\ @domain_cloud) do
    host = Map.fetch!(ta_config, "ONLINE_MOCK_HOSTNAME")
    Config.Reader.merge(config, online_mock: [{endpoint, [url: [host: host <> domain]]}])
  end

  def configure_website_inflation(config, ta_config) do
    case Map.fetch(ta_config, "WEBSITE_INFLATION_KB") do
      {:ok, website_inflation_kb} ->
        Config.Reader.merge(config, online_mock: [website_inflation_kb: website_inflation_kb])

      _ ->
        config
    end
  end

  defp configure_cookie_enforcement(config, ta_config, endpoint, key) do
    case Map.fetch(ta_config, "ONLINEMOCK_COOKIE_ENFORCEMENT_RULES") do
      {:ok, %{^key => rules}} ->
        required = Map.get(rules, "require", %{})
        prohibited = Map.get(rules, "prohibit", %{})

        Config.Reader.merge(
          config,
          online_mock: [{endpoint, [required_cookies: required, prohibited_cookies: prohibited]}]
        )

      _ ->
        config
    end
  end

  @log_levels [:debug, :info, :notice, :warning, :error, :critical, :alert, :emergency]

  defp configure_log_level(config, ta_config) do
    with {:ok, level} <- Map.fetch(ta_config, "online_mock_log_level"),
         level when level in @log_levels <- String.to_existing_atom(level) do
      Config.Reader.merge(config, logger: [level: level])
    else
      _ -> config
    end
  end
end
