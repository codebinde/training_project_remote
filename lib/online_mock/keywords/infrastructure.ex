defmodule OnlineMock.Keywords.Infrastructure do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  @doc """
  Wait for the `:show` action of `OnlineMockInfrastructure.HomeController` to be logged.
  """
  @keyword "Wait Until Device Infrastructure Home Document Is Fetched"
  @spec wait_infrastructure_home :: String.t()
  def wait_infrastructure_home do
    GenServer.call(@event_server_name, {:await, :infrastructure_home_show}, @timeout_keyword_wait)
  end

  @doc """
  Wait for the `:show` action of `OnlineMockInfrastructure.TimeController` to be logged.
  """
  @keyword "Wait Until Time Is Fetched"
  @spec wait_infrastructure_time :: :show
  def wait_infrastructure_time do
    GenServer.call(
      @event_server_name,
      {:await, OnlineMockInfrastructure.TimeController, filter: fn x -> x == :show end},
      @timeout_keyword_wait
    )
  end

  @keyword_doc """
  Makes the online mock return an invalid home document.
  ...
  ...  After using this keyword, the returned JSON by the commerce home document
  ...  will have a link missing.
  """
  @keyword "Make Commerce Home Document Invalid"
  def make_commerce_home_doc_invalid do
    OnlineMock.State.put(
      [Access.key(OnlineMockCookidoo.Commerce, %{}), :missing_link],
      true
    )
  end

  @keyword_doc """
  Makes the online mock return a valid home document (default).
  ...
  ...  This keyword can be used to reset the effects caused by
  ...  ``Make Commerce Home Document Invalid``. The commerce home document
  ...  will contain a valid JSON.
  """
  @keyword "Make Commerce Home Document Valid"
  def make_commerce_home_doc_valid do
    OnlineMock.State.pop([OnlineMockCookidoo.Commerce, :missing_link])
    :ok
  end
end
