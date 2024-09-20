defmodule OnlineMock.PKI do
  @moduledoc """
  A module to manage the public key infrastructure used by OnlineMock.

  ## Configuration

  Certificates are configured under the root key `PKI` in the file `config/pki.exs` which is
  imported in `config/config.exs`. A static certificate stored under `priv/certificates/` is
  configured using the atom `:priv`.

  To dynamically configure a certificate at runtime a tuple `{:mfa, {Module, :function, args}}` may
  be used as the value at any point inside a keyword list of a configuration to be passed to
  `PKI.Cert.tbs/1`. The tuple is replaced by the value returned by the function `:function` of
  module `Module` caled with arguments `args`. This is done whenever the configuration is evaluated
  (e.g. when the application is started).

  ### Example

      config :online_mock, PKI,
        static_cert: :priv,

        dynamic_cert: [
          serial_number: 1,
          issuer: :static_cert,
          subject: [
            commonName: {:mfa, {OnlineMock.PKI, :host, [Endpoint]}}
          ]
        ]
  """

  use Supervisor

  require Logger

  @table Module.concat(__MODULE__, Table)

  ## Interface

  def start_link(arg) do
    Supervisor.start_link(__MODULE__, arg, name: __MODULE__)
  end

  def config_change do
    fill_table()
  end

  @spec lookup_key(name :: atom, format) ::
          {:RSAPrivateKey | :DSAPrivateKey | :ECPrivateKey | :PrivateKeyInfo,
           :public_key.der_encoded()}
          | :public_key.private_key()
        when format: :der | :asn1
  def lookup_key(name, format) do
    :ets.lookup_element(@table, name, 2)[format]
  end

  @spec lookup_cert(name :: atom, format) ::
          {:Certificate, :public_key.der_encoded()}
          | ASN1.PublicKey."OTPCertificate"()
          | ASN1.PublicKey."Certificate"()
        when format: :der | :otp | :plain
  def lookup_cert(name, format) when format in [:der, :otp, :plain] do
    :ets.lookup_element(@table, name, 3)[format]
  end

  ## Callbacks

  @impl Supervisor
  def init([]) do
    :ets.new(@table, [:named_table, :public, read_concurrency: true])
    fill_table()
    Supervisor.init([], strategy: :one_for_one)
  end

  defp fill_table do
    Application.fetch_env!(:online_mock, PKI)
    |> Enum.concat(Application.fetch_env!(:online_mock, Auth))
    |> Enum.each(&configure_cert/1)

    :ok
  end

  defp configure_cert({name, :priv}) do
    cert = read_cert_file(name)
    :ets.insert(@table, {name, read_key_file(name), cert})
  end

  defp configure_cert({name, config}) do
    config = do_configure_cert(config)
    pki_entry = create_cert(config, name)
    :ets.insert(@table, pki_entry)
  end

  defp do_configure_cert(config) do
    for {key, value} <- config do
      case value do
        {:mfa, {module, function, args}} ->
          {key, apply(module, function, args)}

        value when is_list(value) ->
          {key, do_configure_cert(value)}

        value ->
          {key, value}
      end
    end
  end

  @doc false
  def create_cert(config, name) do
    %{asn1: key_asn1} = key = get_or_create_key(name)
    public_key = PKI.Key.extract_public_key(key_asn1)

    cert_der =
      config
      |> Keyword.put(:public_key, public_key)
      |> sign_cert()

    write_cert_file(name, cert_der, System.get_env("INT_TESTING_LOG_FILE_DIR"))

    cert = %{
      der: {:Certificate, cert_der},
      otp: :public_key.pkix_decode_cert(cert_der, :otp),
      plain: :public_key.pkix_decode_cert(cert_der, :plain)
    }

    {name, key, cert}
  end

  defp sign_cert(config) do
    config
    |> Keyword.put(:issuer, lookup_cert(config[:issuer], :otp))
    |> PKI.Cert.tbs()
    |> :public_key.pkix_sign(lookup_key(config[:issuer], :asn1))
  end

  defp read_key_file(name) do
    [{type, der, :not_encrypted}] = load_file("keys/#{name}.key")
    asn1 = :public_key.der_decode(type, der)
    %{der: {type, der}, asn1: asn1}
  end

  defp read_cert_file(name) do
    [{type, der, :not_encrypted}] = load_file("certificates/#{name}.pem")
    otp = :public_key.pkix_decode_cert(der, :otp)
    plain = :public_key.pkix_decode_cert(der, :plain)
    %{der: {type, der}, otp: otp, plain: plain}
  end

  defp load_file(rel_path) do
    :code.priv_dir(:online_mock)
    |> Path.join(rel_path)
    |> File.read!()
    |> :public_key.pem_decode()
  end

  defp get_or_create_key(name) do
    file = Path.join(:code.priv_dir(:online_mock), "keys/#{name}.key")

    if File.exists?(file) do
      read_key_file(name)
    else
      create_key(file)
    end
  end

  defp create_key(file) do
    key_asn1 = PKI.Key.generate_rsa_key()
    key_der = :public_key.der_encode(:RSAPrivateKey, key_asn1)
    write_key(key_der, file)
    %{der: {:RSAPrivateKey, key_der}, asn1: key_asn1}
  end

  defp write_key(key_der, file) do
    key_pem = :public_key.pem_encode([{:RSAPrivateKey, key_der, :not_encrypted}])
    File.write!(file, key_pem)
  end

  defp write_cert_file(_name, _cert_der, nil) do
  end

  defp write_cert_file(name, cert_der, dir) do
    id = System.unique_integer([:positive])
    Logger.debug("Writing certificate #{name}-#{id}")
    cert_pem = :public_key.pem_encode([{:Certificate, cert_der, :not_encrypted}])
    dir = Path.join(dir, "certificates")
    File.mkdir_p!(dir)
    Path.join(dir, "#{name}-#{id}.pem") |> File.write!(cert_pem)
  end

  @doc """
  A function to be used to dynamically configure the host.
  """
  def host(endpoint) do
    Application.fetch_env!(:online_mock, endpoint)
    |> Keyword.fetch!(:url)
    |> Keyword.fetch!(:host)
  end

  @doc """
  A function to be used to dynamically configure the port.
  """
  def port(endpoint, scheme) do
    Application.fetch_env!(:online_mock, endpoint)
    |> Keyword.fetch!(scheme)
    |> Keyword.fetch!(:port)
  end

  @doc """
  A function to be used to dynamically configure the URI of an OCSP responder.
  """
  def ocsp_uri(path \\ "") do
    host = host(OnlineMockOCSP.Endpoint)
    port = port(OnlineMockOCSP.Endpoint, :http)
    {:uniformResourceIdentifier, "http://#{host}:#{port}" <> path}
  end

  @doc """
  A function to be used to dynamically configure a key that accepts a `utcTime`-value.
  """
  def utc_time(offset \\ nil)

  def utc_time(nil) do
    time = OnlineMock.DateTime.utc_now() |> ASN1.utc_time()
    {:utcTime, time}
  end

  def utc_time(offset) do
    time =
      OnlineMock.DateTime.utc_now()
      |> OnlineMock.DateTime.add(offset)
      |> ASN1.utc_time()

    {:utcTime, time}
  end

  @doc """
  A function to be used to dynamically configure `subjectAltName` based on the configured host.
  """
  def subject_alt_name(endpoint) do
    [{:dNSName, host(endpoint)}]
  end

  def certificate_expired(cert_name) do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth, cert_name]) do
      :expired -> utc_time({:hour, -12})
      _ -> nil
    end
  end

  def token_signing_usage do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth, :token_key_usage]) do
      nil -> {[:digitalSignature], :critical}
      :encryption -> {[:keyEncipherment], :critical}
    end
  end
end
