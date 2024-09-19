defmodule OnlineMockInfrastructure.RequestControllerTest do
  use OnlineMockInfrastructure.ConnCase
  require ASN1.PublicKey

  test "GET /time", %{conn: conn} do
    challenge = Base.url_encode64("Challenge")
    conn = get(conn, "/time", challenge: challenge)

    response_challenge =
      conn
      |> response(200)
      |> Base.decode64!()
      |> PKI.decode!(:ContentInfo)
      |> ASN1.PublicKey."ContentInfo"(:content)
      |> ASN1.PublicKey."SignedData"(:contentInfo)
      |> ASN1.PublicKey."ContentInfo"(:content)

    assert response_challenge == "Challenge"
  end
end
