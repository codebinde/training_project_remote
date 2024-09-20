defmodule OnlineMockEST.CACertsController do
  @moduledoc false

  use OnlineMockEST, :controller

  def show(conn, _params) do
    case OnlineMock.State.get([:ca_certs_response]) do
      :internal_server_error ->
        send_resp(conn, :internal_server_error, "")

      _ ->
        root_cert = OnlineMock.PKI.lookup_cert(:vorwerk_root, :plain)
        signer_cert = root_cert

        body =
          PKI.CMS.make_signed_data([], nil, certificates: [signer_cert, root_cert])
          |> PKI.encode!()
          |> Base.encode64()

        conn
        |> put_resp_content_type("application/pkcs7-mime")
        |> put_resp_header("content-transfer-encoding", "base64")
        |> send_resp(200, body)
    end
  end
end
