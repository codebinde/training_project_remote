defmodule OnlineMockCookidoo.Ownership.OfflineRecipesJSON do
  @moduledoc false

  def index(_assigns) do
    %{
      "recipes" => OnlineMock.Data.OwnershipList.get()
    }
  end
end
