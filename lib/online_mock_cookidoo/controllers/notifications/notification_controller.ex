defmodule OnlineMockCookidoo.Notifications.NotificationController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug Plug.EventLog, [event: __MODULE__] when action == :index

  def index(conn, %{"lang" => lang}) do
    notifications =
      for {id, %{title: title}} <- list_notifications() do
        %{id: id, uri: url(~p"/notifications/#{lang}/#{id}"), title: title}
      end

    json(conn, %{notifications: notifications})
  end

  def show(conn, %{"lang" => _lang, "id" => id}) do
    case get_notification(id) do
      %{title: title, notification: notification} ->
        conn
        |> put_format("html")
        |> render(:show, title: title, notification: notification)

      nil ->
        send_resp(conn, :not_found, "Not Found")
    end
  end

  def create(conn, %{"id" => id}) do
    delete_notification(id)
    send_resp(conn, :ok, "Deleted")
  end

  def put_notification(title, notification) do
    id = "#{System.unique_integer([:positive, :monotonic])}"

    OnlineMock.State.update(
      [Access.key(__MODULE__, [])],
      &List.insert_at(&1, -1, {id, %{title: title, notification: notification}})
    )

    id
  end

  def get_notification(id) do
    key_id = fn :get, notifications, next ->
      case List.keyfind(notifications, id, 0) do
        nil -> next.(nil)
        {_id, notification} -> next.(notification)
      end
    end

    OnlineMock.State.get([Access.key(__MODULE__, []), key_id])
  end

  def delete_notification(id) do
    OnlineMock.State.update(
      [Access.key(__MODULE__, [])],
      &List.keydelete(&1, id, 0)
    )
  end

  def list_notifications do
    OnlineMock.State.get([Access.key(__MODULE__, [])])
  end

  def delete_notifications do
    OnlineMock.State.put([__MODULE__], [])
  end
end
