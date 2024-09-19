defmodule OnlineMockCookidoo.Profile.HomeController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  plug :invalid_client_cert, __MODULE__

  def show(conn, _params) do
    json(conn, %{
      _links: %{
        self: %{href: current_url(conn)},
        "profile:notification-settings-device": %{href: url(~p"/profile/data-usage")},
        "profile:api-privacy-policy-text": %{href: url(~p"/profile/privacy-policy")},
        "profile:api-usage-box-consents": %{
          href: url(~p"/profile/consent?consentType={consentType}&userDeviceId={userDeviceId}"),
          templated: true
        },
        "profile:api-device-consents": %{href: url(~p"/profile/device-consents")},
        "profile:usage-box-consent-menu": %{
          href: url(~p"/profile/usage-box-consent-menu") <> "{?deviceId}",
          templated: true
        }
      }
    })
  end
end
