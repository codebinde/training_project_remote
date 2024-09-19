defmodule OnlineMockCookidoo.Profile.DeviceConsentsJSON do
  @moduledoc false

  use OnlineMockCookidoo, :verified_routes

  alias OnlineMock.State

  def index(_assigns) do
    redirect_uri = if State.get([:consent, :redirectURI]), do: url(~p"/profile/consent")

    %{
      "userDeviceId" => State.get([:consent, :userDeviceId], "1"),
      "legalAgreements" => [
        %{
          "type" => State.get([:consent, :type], "USAGEBOX"),
          "revision" => State.get([:consent, :revision], "1.0"),
          "status" => State.get([:consent, :status], "accepted"),
          "deviceId" => State.get([:consent, :deviceId], "1")
        }
      ],
      "redirectURI" => redirect_uri
    }
  end
end
