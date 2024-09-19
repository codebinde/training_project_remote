defmodule OnlineMock.Keywords.Cookidoo.Auth do
  @moduledoc false

  use RemoteLibrary

  @default_token_expiration_time 3_600

  @keyword_doc """
  Registers a client via a secret for OpenID-related client authentication.

      - ``secret`` - Either a username and password split by ``:`` or a password in which case
                     ``nwot-live-v2`` is chosen as the username.
                     Note that the username needs to start either with ``nwot-live-`` or
                     ``device-nonprod-``. The keyword fails otherwise.
  """
  @keyword "Register OpenID Client"
  def register_openid_client(secret) do
    {user, pass} =
      case String.split(secret, ":") do
        [pass] -> {"nwot-live-v2", pass}
        ["nwot-live-" <> _ = user, pass] -> {user, pass}
        ["device-nonprod-" <> _ = user, pass] -> {user, pass}
      end

    OnlineMock.State.put([OnlineMockCookidoo.Auth, :client, :user], URI.encode_www_form(user))
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :client, :pass], URI.encode_www_form(pass))
  end

  @keyword_doc """
  Configures OnlineMock to use expired issuing certificate to sign ID token signing keys.
  """
  @keyword "Configure Expired Intermediate Certificate"
  def configure_expired_intermediate_cert() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :issuing], :expired)
    OnlineMock.PKI.config_change()
    :ok
  end

  @keyword_doc """
  Configures OnlineMock to consider default issuing signing certificate to be revoked.
  """
  @keyword "Configure Revoked Intermediate Certificate"
  def configure_revoked_issuing_cert do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :issuing], :revoked)
  end

  @keyword_doc """
  Configures OnlineMock to use default issuing certificate to sign ID token signing keys.
  """
  @keyword "Reset Intermediate Certificate"
  def reset_intermediate_cert() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :issuing], nil)
    OnlineMock.PKI.config_change()
    :ok
  end

  @keyword_doc """
  Configures OnlineMock to certify published signing key shall be used for encryption only.""
  """
  @keyword "Set Certified Key Usage To Encryption"
  def configure_key_usage() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :token_key_usage], :encryption)
    OnlineMock.PKI.config_change()
    :ok
  end

  @keyword_doc """
  Configures OnlineMock to certify published signing key shall be used for encryption only.""
  """
  @keyword "Set Certified Key Usage To Signing"
  def reset_key_usage() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :token_key_usage], nil)
    OnlineMock.PKI.config_change()
    :ok
  end

  @keyword_doc """
  Configures OnlineMock to use expired certificate for ID token signing keys.
  """
  @keyword "Configure Expired Key Certificate"
  def configure_expired_key_cert() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :token_signing], :expired)
    OnlineMock.PKI.config_change()
    :ok
  end

  @keyword_doc """
  Configures OnlineMock to use default, valid certificate for ID token signing keys.
  """
  @keyword "Reset Key Certificate"
  def reset_key_cert() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :token_signing], nil)
    OnlineMock.PKI.config_change()
    :ok
  end

  @keyword_doc """
  Configures OnlineMock to use ES256 algorithm for token signing.
  """
  @keyword "Configure Auth Token Signing With ES256"
  def configure_token_signing_with_es256() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :algorithm], "ES256")
  end

  @keyword_doc """
  Resets OnlineMock Token Signing Algorithm to RS256
  """
  @keyword "Configure Auth Token Signing With RS256"
  def reset_token_signing() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :algorithm], nil)
  end

  @keyword_doc """
  Cycle published signing keys for Token Endpoint

  Note: This keyword cycles just the keys published by the JSON Web Key Set Controller.
  In order to also cycle the keys used for token signing, also call the keyword
  _Cycle Token Signing Keys_.
  """
  @keyword "Cycle Published Signing Keys"
  def cycle_published_signing_keys() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :key_cycle_rsa], :token_signing_rsa_new)

    OnlineMock.State.put(
      [OnlineMockCookidoo.Auth.Token, :key_cycle_ecdsa],
      :token_signing_ecdsa_new
    )
  end

  @keyword_doc """
  Reset published signing keys for Token Endpoint

  Note: This keyword resets just the keys published by the JSON Web Key Set Controller.
  In order to also reset the keys used for token signing, also call the keyword
  _Reset Token Signing Keys_.
  """
  @keyword "Reset Published Signing Keys"
  def reset_published_signing_keys() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :key_cycle_rsa], nil)
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :key_cycle_ecdsa], nil)
  end

  @keyword_doc """
  Configures OnlineMock to use different keys for token signing.
  """
  @keyword "Cycle Token Signing Keys"
  def configure_new_token_signing_keys() do
    OnlineMock.State.put(
      [OnlineMockCookidoo.Auth.Token, :rsa_key],
      "keys/token_signing_rsa_new.key"
    )

    OnlineMock.State.put(
      [OnlineMockCookidoo.Auth.Token, :ecdsa_key],
      "keys/token_signing_ecdsa_new.key"
    )
  end

  @keyword_doc """
  Resets OnlineMock to use the default key for token signing.
  """
  @keyword "Reset Token Signing Keys"
  def reset_token_signing_keys() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :rsa_key], nil)
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :ecdsa_key], nil)
  end

  @keyword_doc """
  Configures OnlineMock Token Endpoint to use different issuer claim.
  """
  @keyword "Configure Iss Claim Error"
  def configure_wrong_iss_claim() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :iss], :wrong)
  end

  @keyword_doc """
  Resets OnlineMock Token Endpoint issuer claim.
  """
  @keyword "Reset Iss Claim Error"
  def reset_iss_claim() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :iss], nil)
  end

  @keyword_doc """
  Configures OnlineMock Token Endpoint to use different audience claim.
  """
  @keyword "Configure Aud Claim Error"
  def configure_wrong_aud_claim() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :aud], :wrong)
  end

  @keyword_doc """
  Resets OnlineMock Token Endpoint audience claim.
  """
  @keyword "Reset Aud Claim Error"
  def reset_aud_claim() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :aud], nil)
  end

  @keyword_doc """
  Configures OnlineMock to issue tokens with specified expiration time.
  ...
  ...    - ``expiration_time_s`` - The expiration time in seconds for the token (Default: 3600)
  ...
  ... *Examples*
  ... | _Configure Token Expiration Time_ | expiration_time_s=60 |
  """
  @keyword "Configure Token Expiration Time"
  @keyword_args %{_: :*, expiration_time_s: {@default_token_expiration_time, "int"}}
  def configure_token_expiration_time(expiration_time_s) do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :expiration_time], expiration_time_s)
  end

  @keyword_doc """
  Resets Token expiration time to default value
  """
  @keyword "Reset Token Expiration Time"
  def reset_token_expiration_time() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :expiration_time], nil)
  end

  @keyword_doc """
  Configures OnlineMock Token Endpoint to respond with an error on consecutive requests.
  ...
  ...    - ``grant_type`` - The type of grant which should respond with an error
  ...    - ``error`` - The specific error to be contained in the response
  """
  @keyword "Configure Auth Token Error"
  def configure_error(grant_type, error) do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :error, grant_type], error)
  end

  @keyword_doc """
  Revokes any configured error of OnlineMock Token Endpoint.
  ...
  ...    - ``grant_type`` - The type of grant whose error should be revoked
  """
  @keyword "Configure No Auth Token Error"
  def configure_error(grant_type) do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :error, grant_type], nil)
  end

  @keyword_doc """
  Blocks the Auth controller to not respond until it is unlocked.
  """
  @keyword "Lock Auth Token Controller"
  def lock do
    OnlineMock.LockHandle.lock(OnlineMockCookidoo.Auth.TokenController)
  end

  @keyword_doc """
  Unlocks the previously locked Auth controller
  """
  @keyword "Unlock Auth Token Controller"
  def unlock do
    OnlineMock.LockHandle.unlock(OnlineMockCookidoo.Auth.TokenController)
  end

  @keyword_doc """
  Configures OnlineMock Authorization Endpoint to respond with an error on consecutive requests.
  ...
  ...    - ``error`` - The specific error to be contained in the response
  """
  @keyword "Configure Auth Request Error"
  def configure_auth_error(error) do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :auth_request_error], error)
  end

  @keyword_doc """
  Revokes any configured error of OnlineMock Authorization Endpoint.
  """
  @keyword "Configure No Auth Request Error"
  def configure_auth_error() do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :auth_request_error], nil)
  end

  @keyword_doc """
  Enables auth_time claim in ID Token for currently configured user.
  """
  @keyword "Enable Auth Time Claim"
  def enable_auth_time_claim do
    user = OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user])
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], %{user => :iat})
  end

  @keyword_doc """
  Configure auth_time claim error in ID Token for currently configured user.
  """
  @keyword "Configure Auth Time Claim Error"
  def configure_auth_time_claim_error do
    user = OnlineMock.State.get([OnlineMockCookidoo.Auth, :client, :user])
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], %{user => :error})
  end

  @keyword_doc """
  Disable auth_time claim in ID Token.
  """
  @keyword "Disable Auth Time Claim"
  def disable_auth_time_claim do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :auth_time], nil)
  end

  @keyword_doc """
  Configure ID Token to use wrong subject claim.
  """
  @keyword "Configure Wrong Subject Claim"
  def configure_wrong_sub_claim do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :subject], :wrong_subject)
  end

  @keyword_doc """
  Configure ID Token to use default subject claim.
  """
  @keyword "Reset Subject Claim"
  def reset_sub_claim do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :subject], nil)
  end

  @keyword "Set Explicit Refresh AccessToken"
  def set_explicit_refresh_access_token do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :access_token], "RefreshedAccessToken")
  end

  @keyword "Set Default AccessToken"
  def set_default_access_token do
    OnlineMock.State.put([OnlineMockCookidoo.Auth.Token, :access_token], nil)
  end

  @keyword_doc """
  Send user authorization as part of device authorization flow
  """
  @keyword "Confirm User Authorization"
  def confirm_user_authorization do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], :ok)
  end

  @keyword_doc """
  Clear user authorization for device authorization flow
  """
  @keyword "Clear User Authorization"
  def clear_user_authorization do
    OnlineMock.State.put([OnlineMockCookidoo.Auth, :device_auth_user_confirm], nil)
  end
end
