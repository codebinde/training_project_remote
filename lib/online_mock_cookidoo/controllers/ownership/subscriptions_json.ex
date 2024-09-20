defmodule OnlineMockCookidoo.Ownership.SubscriptionsJSON do
  @moduledoc false

  alias OnlineMock.State

  def index(_assigns) do
    [
      %{
        active: State.get([:subscription, :active], true),
        expires: State.get([:subscription, :expires], "2029-01-25T00:00:00.000Z"),
        type: State.get([:subscription, :type], "REGULAR"),
        status: State.get([:subscription, :status], "ACTIVE"),
        _created: State.get([:subscription, :_created], "2019-11-05T08:22:22.000Z"),
        _modified: State.get([:subscription, :_modified], "2019-11-05T11:16:58.000Z"),
        autoRenewalProduct: State.get([:subscription, :autoRenewalProduct], true),
        subscriptionLevel: State.get([:subscription, :subscriptionLevel], "NONE")
      }
    ]
  end
end
