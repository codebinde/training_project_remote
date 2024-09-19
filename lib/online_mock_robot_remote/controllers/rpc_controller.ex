defmodule OnlineMockRobotRemote.RPCController do
  @moduledoc false

  use OnlineMockRobotRemote, :controller

  import RemoteLibrary.Router,
    only: [send_xml_rpc_resp: 2, send_xml_rpc_resp_and_invoke_stop_remote_server_callback: 2]

  def create(conn, %{method_name: method_name, params: params}) do
    case RemoteLibrary.Caller.robot_call(method_name, params) do
      {:ok, response} ->
        send_xml_rpc_resp(conn, response)

      {:stop_remote_server, response} ->
        send_xml_rpc_resp_and_invoke_stop_remote_server_callback(conn, response)

      {:not_found, response} ->
        send_resp(conn, :not_found, response)
    end
  end
end
