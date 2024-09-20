defmodule OnlineMock.Keywords.EST do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  @doc """
  Wait for the `:create` action of `OnlineMockEST.SimpleenrollController` to be logged.
  """
  @keyword "Wait Until Client Certificate Is Requested"
  @spec wait_est_simpleenroll :: :create
  def wait_est_simpleenroll do
    GenServer.call(
      @event_server_name,
      {:await, OnlineMockEST.SimpleenrollController},
      @timeout_keyword_wait
    )
  end

  @keyword "Configure CACerts Request To Fail"
  @spec invalidate_cacerts :: :ok
  def invalidate_cacerts do
    OnlineMock.State.put([:ca_certs_response], :internal_server_error)
    :ok
  end

  @keyword "Configure CACerts Request To Succeed"
  @spec validate_cacerts :: :ok
  def validate_cacerts do
    OnlineMock.State.put([:ca_certs_response], :ok)
    :ok
  end
end
