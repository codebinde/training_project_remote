defmodule OnlineMockEST.SimpleenrollController do
  @moduledoc false

  use OnlineMockEST, :controller

  alias ASN1.PublicKey

  require Logger
  require PublicKey

  @id_ec_public_key :"OTP-PUB-KEY"."id-ecPublicKey"()
  @rsa_encryption :"OTP-PUB-KEY".rsaEncryption()

  def create(conn, _params) do
    OnlineMock.log_event(__MODULE__, conn.request_path)

    {:ok, body, conn} = read_body(conn)

    request_info = decode_request_info(body)
    client_cert = client_cert(extract_subject(request_info), extract_public_key(request_info))

    body =
      PKI.CMS.make_signed_data([], nil, certificates: [PKI.Cert.transform(client_cert, :plain)])
      |> PKI.encode!()
      |> Base.encode64()

    conn
    |> put_resp_content_type("application/pkcs7-mime; smime-type=certs-only")
    |> put_resp_header("content-transfer-encoding", "base64")
    |> send_resp(200, body)
  end

  defp decode_request_info(request) do
    request
    |> Base.decode64!()
    |> PKI.decode!(:CertificationRequest)
    |> PublicKey."CertificationRequest"(:certificationRequestInfo)
  end

  defp extract_subject(request_info) do
    request_info
    |> PublicKey."CertificationRequestInfo"(:subject)
    # TODO: Generalize recursive decoding of DER-encoded binaries and use it here
    |> update_in([Access.elem(1), Access.at(0), Access.at(0), Access.elem(2)], fn x ->
      :public_key.der_decode(:X520CommonName, x)
    end)
  end

  defp extract_public_key(request_info) do
    subject_pk_info = PublicKey."CertificationRequestInfo"(request_info, :subjectPKInfo)
    algorithm = PublicKey."CertificationRequestInfo_subjectPKInfo"(subject_pk_info, :algorithm)

    subject_public_key =
      PublicKey."CertificationRequestInfo_subjectPKInfo"(subject_pk_info, :subjectPublicKey)

    decode_public_key(algorithm, subject_public_key)
  end

  defp decode_public_key({_, @id_ec_public_key, {_, parameters}}, point) do
    parameters = :public_key.der_decode(:EcpkParameters, parameters)
    {PublicKey."ECPoint"(point: point), parameters}
  end

  defp decode_public_key({_, @rsa_encryption, _}, public_key) do
    :public_key.der_decode(:RSAPublicKey, public_key)
  end

  defp client_cert(subject, public_key) do
    {issuer_key, issuer_cert} = lookup_issuer(:vorwerk_root)

    (validity_period() ++ [subject: subject, issuer: issuer_cert, public_key: public_key])
    |> PKI.Cert.tbs()
    |> :public_key.pkix_sign(issuer_key)
  end

  defp lookup_issuer(issuer) do
    {OnlineMock.PKI.lookup_key(issuer, :asn1), OnlineMock.PKI.lookup_cert(issuer, :otp)}
  end

  defp validity_period() do
    now = OnlineMock.DateTime.utc_now()

    for {key, value} <- [not_before: now, not_after: OnlineMock.DateTime.add(now, {:day, 2})] do
      {key, {:utcTime, ASN1.utc_time(value)}}
    end
  end
end
