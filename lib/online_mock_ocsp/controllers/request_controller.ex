defmodule OnlineMockOCSP.RequestController do
  @moduledoc false

  use OnlineMockOCSP, :controller

  require ASN1.PublicKey

  # OCSP default values
  @this_update_default {:hour, -1}
  @next_update_default {:hour, 1}

  defp signer(issuer), do: String.to_existing_atom(issuer <> "_ocsp")

  def create(conn, %{"_ocsp_request" => request, "issuer" => issuer}) do
    OnlineMock.log_event(:ocsp_request, :create)
    render_response(conn, request, signer(issuer))
  end

  def create(conn, %{"_ocsp_request" => request}) do
    OnlineMock.log_event(:ocsp_request, :create)
    render_response(conn, request, :vorwerk_intermediate)
  end

  def show(conn, %{"ocsp_request" => request, "issuer" => issuer}) do
    OnlineMock.log_event(:ocsp_request, :show)

    request =
      request
      |> decode_base64()
      |> parse_request()

    render_response(conn, request, signer(issuer))
  end

  def show(conn, %{"ocsp_request" => request}) do
    OnlineMock.log_event(:ocsp_request, :show)

    request =
      request
      |> decode_base64()
      |> parse_request()

    render_response(conn, request, :vorwerk_intermediate)
  end

  defp decode_base64(encoded) do
    Base.decode64!(encoded, padding: false)
  rescue
    _ -> raise Plug.BadRequestError
  end

  defp parse_request(encoded) do
    PKI.decode!(encoded, :OCSPRequest)
  rescue
    _ -> raise Plug.BadRequestError
  end

  defp render_response(conn, request, signer) do
    signer_key = OnlineMock.PKI.lookup_key(signer, :asn1)
    signer_cert = OnlineMock.PKI.lookup_cert(signer, :plain)

    subject =
      signer_cert
      |> ASN1.PublicKey."Certificate"(:tbsCertificate)
      |> ASN1.PublicKey."TBSCertificate"(:subject)

    opts = certs(signer, signer_cert) ++ calculate_ocsp_update_times() ++ get_revoked_status()

    ocsp_response =
      PKI.OCSP.make_response(request, {:byName, subject}, signer_key, opts) |> PKI.encode!()

    render(conn, :show, ocsp_response: ocsp_response)
  end

  defp get_revoked_status do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth, :issuing]) do
      :revoked ->
        now = OnlineMock.DateTime.utc_now()
        [revoked_info: [time: ASN1.generalized_time(now)]]

      _other_status ->
        []
    end
  end

  defp certs(:vorwerk_intermediate, _), do: []
  defp certs(_, signer_cert), do: [certs: [signer_cert]]

  defp calculate_ocsp_update_times() do
    now = OnlineMock.DateTime.utc_now()

    [
      this_update: calculate_update([:ocsp_this_update], now, @this_update_default),
      next_update: calculate_update([:ocsp_next_update], now, @next_update_default),
      produced_at: ASN1.generalized_time(now)
    ]
  end

  defp calculate_update(state_path, datetime, default_offset) do
    case OnlineMock.State.get(state_path) do
      :not_set ->
        :asn1_NOVALUE

      :now ->
        ASN1.generalized_time(datetime)

      :default ->
        datetime
        |> OnlineMock.DateTime.add(default_offset)
        |> ASN1.generalized_time()

      update ->
        update
    end
  end
end
