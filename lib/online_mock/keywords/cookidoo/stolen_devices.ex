defmodule OnlineMock.Keywords.Cookidoo.StolenDevices do
  @moduledoc false

  use RemoteLibrary

  @keyword "Unblock Device"
  @keyword_doc """
  Configures OnlineMock to report the device as not being blocked (stolen).
  ...
  ...   Every subsequent request for the status whether the device is stolen is responded with an
  ...   answer reporting the device as not being blocked.
  """
  def unblock_device do
    OnlineMock.State.pop([:stolen_devices_status])
    :ok
  end

  @keyword "Block Device"
  @keyword_args %{reason: {"VN-12345", nil}}
  @keyword_doc """
  Configures OnlineMock to report the device as being blocked (stolen).
  ...
  ...   Every subsequent request for the status whether the device is stolen is responded with an
  ...   answer reporting the device as being blocked. The metadata ``"created"`` is set to the date
  ...   and time (UTC) when the keyword has been called.
  ...
  ...   - ``reason`` - Metadata which describes the reason why device is blocked
  """
  def block_device(reason) do
    OnlineMock.State.put([:stolen_devices_status], %{
      blocked: true,
      created: created(),
      reason: reason
    })

    :ok
  end

  defp created do
    NaiveDateTime.utc_now()
    |> NaiveDateTime.truncate(:second)
    |> NaiveDateTime.to_string()
    |> String.replace(":", "")
  end

  @keyword "Configure Error For Response of Stolen Devices Status"
  @keyword_args %{status: {404, "int"}}
  @keyword_doc """
  Configures OnlineMock to respond with an error when the status of stolen device is checked.
  ...
  ...    Every subsequent request for the status whether the device is stolen is responded with the
  ...    status code ``status``.
  ...
  ...    - ``status`` - Status code of the response
  """
  def error(status) do
    OnlineMock.State.put([:stolen_devices_status], {:error, status})
  end
end
