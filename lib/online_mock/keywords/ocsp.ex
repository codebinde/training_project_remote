defmodule OnlineMock.Keywords.OCSP do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  @doc """
  Waits for an OCSP request.
  """
  @keyword "Wait Until OCSP Request Is Made"
  @keyword_doc @doc
  @spec wait_ocsp_request :: :create | :show
  def wait_ocsp_request do
    GenServer.call(@event_server_name, {:await, :ocsp_request}, @timeout_keyword_wait)
  end

  @doc """
  Checks that no OCSP request has been made.
  """
  @keyword "No OCSP Request Should Have Been Made"
  @keyword_doc @doc
  @spec ocsp_request_is_nil! :: nil
  def ocsp_request_is_nil! do
    nil = GenServer.call(@event_server_name, {:current_value, :ocsp_request})
  end

  @doc """
  Returns the list of actions triggered by OCSP requests.
  """
  @keyword "Get Actions For OCSP Requests"
  @keyword_doc @doc
  @spec get_ocsp_requests :: [String.t()]
  def get_ocsp_requests do
    GenServer.call(@event_server_name, {:values, :ocsp_request})
  end
end
