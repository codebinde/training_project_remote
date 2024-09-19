defmodule OnlineMockOCSP.RequestControllerTest do
  use OnlineMockOCSP.ConnCase

  require ASN1.PublicKey

  test "GET /:ocsp_request", %{conn: conn} do
    request_cert = OnlineMock.PKI.lookup_cert(:vorwerk_issuing, :plain)
    conn = get(conn, "/" <> ocsp_request(request_cert))

    certs =
      conn
      |> response(200)
      |> basic_response()
      |> ASN1.PublicKey."BasicOCSPResponse"(:certs)

    assert certs == :asn1_NOVALUE
  end

  test "GET /:issuer/:ocsp_request", %{conn: conn} do
    request_cert = OnlineMock.PKI.lookup_cert(:time_signing, :plain)
    conn = get(conn, "/vorwerk_issuing/" <> ocsp_request(request_cert))

    certs =
      conn
      |> response(200)
      |> basic_response()
      |> ASN1.PublicKey."BasicOCSPResponse"(:certs)

    assert certs == [OnlineMock.PKI.lookup_cert(:vorwerk_issuing_ocsp, :plain)]
  end

  defp ocsp_request(cert) do
    [cert]
    |> PKI.OCSP.make_request()
    |> PKI.encode!()
    |> Base.encode64(padding: false)
    |> URI.encode_www_form()
  end

  defp basic_response(response) do
    response_bytes =
      response
      |> PKI.decode!(:OCSPResponse)
      |> ASN1.PublicKey."OCSPResponse"(:responseBytes)
      |> ASN1.PublicKey."ResponseBytes"(:response)

    :public_key.der_decode(:BasicOCSPResponse, response_bytes)
  end
end
