defmodule OnlineMock.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    setup_ets_tables()
    register_keywords()

    opts = [strategy: :one_for_one, max_restarts: 0, name: OnlineMock.Supervisor]
    Supervisor.start_link(children(), opts)
  end

  # Tell Phoenix to update the endpoint configuration whenever the application is updated.
  def config_change(changed, _new, removed) do
    OnlineMockCloud.Endpoint.config_change(changed, removed)
    OnlineMockCookidoo.Endpoint.config_change(changed, removed)
    OnlineMockInfrastructure.Endpoint.config_change(changed, removed)
    OnlineMockOCSP.Endpoint.config_change(changed, removed)
    OnlineMockRobotRemote.Endpoint.config_change(changed, removed)
    :ok
  end

  defp children do
    [
      {OnlineMock.State, initial_state()},
      OnlineMock.PKI,
      OnlineMock.LockHandle,
      OnlineMock,
      OnlineMockCloud.Endpoint,
      OnlineMockCookidoo.Endpoint,
      OnlineMockOCSP.Endpoint,
      OnlineMockInfrastructure.Endpoint,
      OnlineMockEST.Endpoint,
      OnlineMockRobotRemote.Endpoint
    ]
  end

  defp initial_state do
    %{
      :access_token_watchlist => ["Bearer AccessToken"],
      :config_access_token_response => %{},
      :config_login_response => %{},
      :consent => %{},
      :customlists => [],
      :device_deactivation_body => %{init: 0},
      :enc_recipe_download_available => true,
      :invalid_client_cert => %{},
      :managedlists => [],
      :ocsp_next_update => :default,
      :ocsp_this_update => :default,
      :recipes => %{},
      :reject_client_cert => %{},
      :subscription => %{},
      :video_stream => %{delay: 0, segments: %{}},
      OnlineMockEST.Endpoint => %{},
      OnlineMockInfrastructure.Endpoint => %{},
      OnlineMockOCSP.Endpoint => %{},
      OnlineMockCookidoo.Endpoint => %{},
      OnlineMockCookidoo.Auth => %{
        client: %{user: "nwot-live-v1", pass: "P9aHiy3hRyMbRjEex4WUU4XJVJpqcL7NtHP3Ktwk"}
      },
      OnlineMockCookidoo.Auth.Token => %{error: %{}},
      Plug.UserAgent => %{},
      Plug.StatusResponder => %{},
      OnlineMockCookidoo.Usagebox.UploadController => %{}
    }
  end

  defp setup_ets_tables do
    :ets.new(:sw_image_table, [:named_table, :public])
    :ets.new(:fragments_table, [:named_table, :public, :compressed])
    :ets.new(:files_table, [:named_table, :public])
    :ets.new(:recipe_variants, [:named_table, :public])
  end

  defp register_keywords do
    Enum.each(
      [
        OnlineMock,
        OnlineMock.Keywords.Infrastructure,
        OnlineMock.Keywords.EST,
        OnlineMock.Keywords.OCSP,
        OnlineMock.Keywords.Cookidoo,
        OnlineMock.Keywords.Cookidoo.Auth,
        OnlineMock.Keywords.Cookidoo.Firmware,
        OnlineMock.Keywords.Cookidoo.Notifications,
        OnlineMock.Keywords.Cookidoo.Organize,
        OnlineMock.Keywords.Cookidoo.Ownership,
        OnlineMock.Keywords.Cookidoo.Planning,
        OnlineMock.Keywords.Cookidoo.RecipeAssets,
        OnlineMock.Keywords.Cookidoo.StolenDevices,
        OnlineMock.Keywords.Cookidoo.Usagebox
      ],
      fn module -> module.register_keywords() end
    )
  end
end
