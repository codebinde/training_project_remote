defmodule OnlineMock.Keywords.Cookidoo.Notifications do
  @moduledoc false

  use RemoteLibrary

  @event_server_name OnlineMock
  @timeout_keyword_wait Application.compile_env!(:online_mock, :timeout_keyword_wait)

  @keyword_doc """
  Creates a new notification.
  ...
  ...    A new notification with a random ID is created.
  ...
  ...    Returns the random ID.
  ...
  ...    - ``title`` - Notification title
  ...    - ``notification`` - Notification text to be shown when opening the notification
  """
  @keyword "Create Notification"
  def create(title, notification) do
    OnlineMockCookidoo.Notifications.NotificationController.put_notification(title, notification)
  end

  @keyword_doc """
  Deletes all existing notifications.
  ...
  ...    All notifications are deleted.
  """
  @keyword "Delete Notifications"
  def delete do
    OnlineMockCookidoo.Notifications.NotificationController.delete_notifications()
  end

  @keyword_doc """
  Waits until the list of stored notifications is requested.
  ...
  ...    Waits with a timeout of #{@timeout_keyword_wait} ms.
  """
  @keyword "Wait Until Notifications Are Fetched"
  def wait_cookidoo_notifications_notification_index do
    GenServer.call(
      @event_server_name,
      {:await, OnlineMockCookidoo.Notifications.NotificationController},
      @timeout_keyword_wait
    )

    :ok
  end
end
