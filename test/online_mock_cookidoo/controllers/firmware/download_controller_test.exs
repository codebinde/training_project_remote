defmodule OnlineMockCookidoo.Firmware.DownloadControllerTest do
  use OnlineMockCookidoo.ConnCase

  setup_all do
    :ets.insert(:fragments_table, {"some key", {"some file", "some data"}})
    :ok
  end

  setup [:setup_chunked]

  describe "show" do
    test "sends download all at once", %{conn: conn} do
      conn = get(conn, ~p"/firmware/some key")
      assert conn.state == :sent
      assert response(conn, 200) == "some data"
    end

    @tag :chunked
    test "sends download chunked", %{conn: conn} do
      conn = get(conn, ~p"/firmware/some key")
      assert conn.state == :chunked
      assert response(conn, 200) == "some data"
    end

    test "renders errors when download is not found", %{conn: conn} do
      conn = get(conn, ~p"/firmware/not-found")
      assert response(conn, 404) == "Not Found"
    end
  end

  defp setup_chunked(%{chunked: true}) do
    OnlineMock.Keywords.Cookidoo.Firmware.configure_download_fragment_chunked("some file", 2, 0)
    :ok
  end

  defp setup_chunked(_) do
    OnlineMock.Keywords.Cookidoo.Firmware.configure_download_fragment_not_chunked("some file")
    :ok
  end
end
