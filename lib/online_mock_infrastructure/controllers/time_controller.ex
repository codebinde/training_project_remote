defmodule OnlineMockInfrastructure.TimeController do
  @moduledoc false

  use OnlineMockInfrastructure, :controller

  plug :put_state, [:time_challenge_response]
  plug :halt_on_error

  def show(conn, %{"challenge" => challenge}) do
    OnlineMock.log_event(__MODULE__, :show)

    challenge = challenge(conn, challenge)
    signer_key = OnlineMock.PKI.lookup_key(:time_signing, :asn1)
    signer_cert = OnlineMock.PKI.lookup_cert(:time_signing, :plain)
    signers = signers(signer_key, signer_cert)
    certificates = certificates(signer_cert)

    data = data(signers, challenge, certificates)

    conn
    |> put_resp_header("content-transfer-encoding", "base64")
    |> text(data)
  end

  defp challenge(conn, challenge) do
    case conn.assigns[:state] do
      :send_invalid_challenge -> ""
      _ -> challenge
    end
    |> Base.url_decode64!(padding: false)
  end

  defp signers(key, cert), do: [{cert, :sha256, key, signed_attributes()}]

  defp signed_attributes do
    signing_time = OnlineMock.DateTime.utc_now()
    [signing_time: [{:utcTime, ASN1.utc_time(signing_time)}]]
  end

  defp certificates(signer_cert) do
    for cert <- [:vorwerk_issuing, :vorwerk_intermediate], reduce: [signer_cert] do
      certificates -> [OnlineMock.PKI.lookup_cert(cert, :plain) | certificates]
    end
  end

  defp data(signers, challenge, certificates) do
    PKI.CMS.make_signed_data(signers, challenge, certificates: certificates)
    |> PKI.encode!()
    |> Base.encode64()
  end

  defp put_state(conn, path) do
    state = OnlineMock.State.get(path)
    assign(conn, :state, state)
  end

  defp halt_on_error(conn, _opts) do
    case conn.assigns[:state] do
      :internal_server_error ->
        conn |> send_resp(:internal_server_error, "") |> halt()

      _ ->
        conn
    end
  end
end
