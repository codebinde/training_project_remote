defmodule OnlineMockCookidoo.Auth.JWTManager do
  @moduledoc false

  use Joken.Config

  require Logger

  @subject "Subject"
  @family_name "Family Name"
  @given_name "Given Name"
  @email "QA_INT@vorwerk.de"
  @default_token_expiration_time 3_600
  @default_rsa_key "keys/token_signing_rsa.key"
  @default_rsa_key_id "RS256 Key ID"
  @new_rsa_key_id "New RS256 Key ID"
  @default_ec_key "keys/token_signing_ecdsa.key"
  @default_ec_key_id "ES256 Key ID"
  @new_ec_key_id "New ES256 Key ID"
  @wrong_iss_claim "https://invalid_issuer.example.com/auth"
  @wrong_aud_claim "WRONG AUDIENCE"
  @wrong_subject "WRONG SUBJECT"

  @impl Joken.Config
  def token_config do
    %{}
    |> add_claim("iss", fn -> get_iss_claim() end, nil)
    |> add_claim("aud", fn -> get_aud_claim() end, nil)
    |> add_claim("exp", fn -> Joken.current_time() + get_token_expiration_time() end, nil)
    |> add_claim("iat", fn -> Joken.current_time() end, nil)
    |> add_claim("family_name", fn -> @family_name end, nil)
    |> add_claim("given_name", fn -> @given_name end, nil)
    |> add_claim("email", fn -> @email end, nil)
    |> add_claim("sub", fn -> get_sub_claim() end, nil)
  end

  defp get_sub_claim do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :subject]) do
      nil -> @subject
      _subject -> @wrong_subject
    end
  end

  def get_iss_claim do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :iss]) do
      nil -> OnlineMockCookidoo.Auth.OpenIDConfigurationController.issuer()
      iss when not is_nil(iss) -> @wrong_iss_claim
    end
  end

  def get_aud_claim do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :aud]) do
      nil -> OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user])
      aud when not is_nil(aud) -> @wrong_aud_claim
    end
  end

  def get_token_expiration_time do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :expiration_time]) do
      nil -> @default_token_expiration_time
      time_s when is_integer(time_s) -> time_s
    end
  end

  defp get_nonce(client_id) do
    %{^client_id => nonce} = OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :nonce])
    OnlineMock.State.update([OnlineMockCookidoo.Auth.Token, :nonce], &Map.drop(&1, [client_id]))
    nonce
  rescue
    _ -> nil
  end

  def signer(nil) do
    signer("RS256")
  end

  def signer("HS" <> _ = alg) do
    Joken.Signer.create(alg, OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user]))
  end

  def signer("RS" <> _ = alg) do
    pem = :code.priv_dir(:online_mock) |> Path.join(get_rsa_key()) |> File.read!()
    Joken.Signer.create(alg, %{"pem" => pem}, %{"kid" => get_rsa_key_id()})
  end

  def signer("ES" <> _ = alg) do
    pem = :code.priv_dir(:online_mock) |> Path.join(get_ecdsa_key()) |> File.read!()
    Joken.Signer.create(alg, %{"pem" => pem}, %{"kid" => get_ecdsa_key_id()})
  end

  defp get_ecdsa_key do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :ecdsa_key]) do
      nil -> @default_ec_key
      key when is_binary(key) -> key
    end
  end

  defp get_ecdsa_key_id do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :ecdsa_key]) do
      nil -> @default_ec_key_id
      key when is_binary(key) -> @new_ec_key_id
    end
  end

  defp get_rsa_key do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :rsa_key]) do
      nil -> @default_rsa_key
      key when is_binary(key) -> key
    end
  end

  defp get_rsa_key_id do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :rsa_key]) do
      nil -> @default_rsa_key_id
      key when is_binary(key) -> @new_rsa_key_id
    end
  end

  @impl Joken.Hooks
  def before_generate(_hook_options, {token_config, extra_claims}) do
    with %{"client_id" => client_id} <- extra_claims do
      case get_nonce(client_id) do
        nil ->
          Logger.debug("No nonce required.")
          {:cont, {token_config, Map.drop(extra_claims, ["client_id"])}}

        nonce ->
          Logger.debug("Nonce taken from record")

          {:cont,
           {token_config, extra_claims |> Map.put("nonce", nonce) |> Map.drop(["client_id"])}}
      end
    else
      extra_claims when is_map(extra_claims) ->
        Logger.debug("No nonce parameter passed.")
        {:cont, {token_config, extra_claims}}

      _error ->
        {:halt,
         {:error,
          "Cannot process extra claims, not a map: " <>
            "#{inspect(extra_claims, limit: :infinity, pretty: true)}"}}
    end
  end

  @impl Joken.Hooks
  def after_generate(_hook_options, {:ok, claims} = result, input) do
    %{"aud" => client_id, "iat" => iat} = claims

    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :auth_time]) do
      nil ->
        Logger.debug("No auth_time configured.")
        {:cont, result, input}

      %{^client_id => :iat} ->
        Logger.debug("Using issuing time as new auth_time.")
        OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], %{client_id => iat})
        {:cont, {:ok, Map.put(claims, "auth_time", iat)}, input}

      %{^client_id => auth_time} ->
        Logger.debug("Using stored auth_time.")
        {:cont, {:ok, Map.put(claims, "auth_time", auth_time)}, input}
    end
  end
end
