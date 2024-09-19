defmodule OnlineMock.Keywords.Cookidoo.Usagebox do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  @keyword "Wait Until Usagebox Log Is Uploaded"
  @keyword_args %{timeout: {@timeout_keyword_wait, "int"}}
  def wait_upload(timeout) do
    GenServer.call(@event_server_name, {:await, :cookidoo_usagebox_upload}, timeout)
  end

  @keyword "Set Usagebox Upload Directory"
  def set_usagebox_upload_directory(dir) do
    OnlineMock.State.put([OnlineMockCookidoo.Usagebox.UploadController, :upload_dir], dir)
    :ok
  end
end
