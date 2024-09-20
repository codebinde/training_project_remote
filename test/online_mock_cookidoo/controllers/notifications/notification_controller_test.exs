defmodule OnlineMockCookidoo.NotificationControllerTest do
  use OnlineMockCookidoo.ConnCase

  alias OnlineMockCookidoo.Notifications.NotificationController

  setup do
    NotificationController.delete_notifications()
  end

  describe "index" do
    test "lists empty notifications if no notification is stored", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer AccessToken")
        |> get(~p"/notifications/LANG")

      assert json_response(conn, 200) == %{"notifications" => []}
    end

    test "lists stored notifications", %{conn: conn} do
      NotificationController.put_notification("Title 1", "Text")
      NotificationController.put_notification("Title 2", "Text")

      conn =
        conn
        |> put_req_header("authorization", "Bearer AccessToken")
        |> get(~p"/notifications/LANG")

      assert %{
               "notifications" => [
                 %{"id" => id_1, "title" => "Title 1", "uri" => uri_1},
                 %{"id" => id_2, "title" => "Title 2", "uri" => uri_2}
               ]
             } = json_response(conn, 200)

      assert uri_1 == url(~p"/notifications/LANG/#{id_1}")
      assert uri_2 == url(~p"/notifications/LANG/#{id_2}")
    end

    test "request denied when no access token is in header", %{conn: conn} do
      conn = get(conn, ~p"/notifications/LANG")

      assert response(conn, 401)
    end

    test "request denied when wrong access token is in header", %{conn: conn} do
      conn =
        conn
        |> put_req_header("authorization", "Bearer WrongToken")
        |> get(~p"/notifications/LANG")

      assert response(conn, 401)
    end
  end

  describe "show" do
    test "retrieves specific stored notification" do
      NotificationController.put_notification("Title 1", "Text")
      id = NotificationController.put_notification("Title 2", "Text")

      notification = NotificationController.get_notification(id)

      assert %{title: "Title 2", notification: "Text"} == notification
    end

    @tag :skip
    test "responds with specific stored notification", %{conn: conn} do
      id = NotificationController.put_notification("Title", "Text")

      conn =
        conn
        |> put_req_header("authorization", "Bearer AccessToken")
        |> get(~p"/notifications/LANG/#{id}")

      assert html_response(conn, 200) =~ "Text"
      assert html_response(conn, 200) =~ "Title"
    end

    test "respond with error page when requesting non-existent notification", %{conn: conn} do
      id = "#{System.unique_integer([:positive, :monotonic])}"

      conn =
        conn
        |> put_req_header("authorization", "Bearer AccessToken")
        |> get(~p"/notifications/LANG/#{id}")

      assert response(conn, 404) == "Not Found"
    end
  end

  describe "create" do
    test "delete notification from list", %{conn: conn} do
      NotificationController.put_notification("Title 1", "Text")
      id = NotificationController.put_notification("Title 2", "Text")

      conn
      |> put_req_header("authorization", "Bearer AccessToken")
      |> post(~p"/notifications/LANG?#{[id: id]}")

      [{_, %{title: title, notification: notification}}] =
        NotificationController.list_notifications()

      assert title == "Title 1"
      assert notification == "Text"
    end
  end
end
