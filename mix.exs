defmodule OnlineMock.MixProject do
  use Mix.Project

  def project do
    [
      app: :online_mock,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  def application do
    [
      mod: {OnlineMock.Application, []},
      extra_applications: [:logger, :runtime_tools, :crypto]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.7.7"},
      {:phoenix_html, "~> 3.3"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:phoenix_live_view, "~> 0.19.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.6"},
      {:yaml_elixir, "~> 2.4"},
      {:joken, "~> 2.6"},
      {:cors_plug, "~> 3.0"},
      {:ex_doc, "~> 0.30", only: :dev, runtime: false},
      {:pki,
       git: "https://gitlab.tmecosys.net/qa-embedded/projects/common/lib/elixir/pki.git",
       ref: "27a6297dd403ec40376e28b6150e683bf7a8feac"},
      {:event_log,
       git: "https://gitlab.tmecosys.net/qa-embedded/projects/common/lib/elixir/event_log.git",
       ref: "cac99c176d185b6e6b920d16d500ea0a9c414adb"},
      {:remote_library,
       git:
         "https://gitlab.tmecosys.net/qa-embedded/projects/common/lib/elixir/remote_library.git",
       ref: "38a4fe1f686436dbdc3c97986c1561716960528d"},
      {:test_automation_framework,
       git:
         "https://gitlab.tmecosys.net/qa-embedded/projects/common/lib/elixir/test_automation_framework.git",
       ref: "980fa94ef56ec5cf4238d977d39b7201f3b31d1e"}
    ]
  end

  defp releases do
    [
      ci: [
        include_executables_for: [:unix],
        config_providers: [
          {OnlineMock.TestAutomationConfigProvider, []}
        ],
        # reboot needed to configure logger via config provider
        # see https://hexdocs.pm/mix/1.15.4/Mix.Tasks.Release.html#module-config-providers
        reboot_system_after_config: true
      ],
      docker: [
        include_executables_for: [:unix],
        runtime_config_path: "config/docker_runtime.exs"
      ]
    ]
  end
end
