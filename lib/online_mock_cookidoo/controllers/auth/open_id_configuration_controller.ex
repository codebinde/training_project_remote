defmodule OnlineMockCookidoo.Auth.OpenIDConfigurationController do
  @moduledoc """
  [OpenID Connect Discovery 1.0 incorporating errata set 1](https://openid.net/specs/openid-connect-discovery-1_0.html)
  """

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    json(conn, %{
      issuer: issuer(),
      authorization_endpoint: url(~p"/auth/authorization-code"),
      token_endpoint: url(~p"/auth/token"),
      end_session_endpoint: url(~p"/auth/end_session"),
      jwks_uri: url(~p"/auth/jwks.json"),
      response_types_supported: ["code"],
      subject_types_supported: ["public"],
      id_token_signing_alg_values_supported: ["RS256", "ES256"],
      scopes_supported: ["openid", "profile", "email", "offline_access"],
      grant_types_supported: ["authorization_code", "refresh_token"],
      claims_supported: ["given_name", "family_name", "email"],
      device_authorization_endpoint: url(~p"/auth/device-authorization")
    })
  end

  def issuer do
    URI.to_string(%{OnlineMockCookidoo.Endpoint.struct_url() | path: "/auth"})
  end
end
