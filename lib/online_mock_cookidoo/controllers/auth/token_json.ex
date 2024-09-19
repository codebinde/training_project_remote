defmodule OnlineMockCookidoo.Auth.TokenJSON do
  @moduledoc false

  def create(%{id_token: id_token, expires_in: expires_in}) do
    %{
      token_type: "Bearer",
      id_token: id_token,
      access_token: get_access_token(),
      refresh_token: "RefreshToken",
      expires_in: expires_in
    }
  end

  def create(%{error: error}) do
    %{error: error}
  end

  defp get_access_token do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :access_token]) do
      nil -> "AccessToken"
      token when is_binary(token) -> token
    end
  end
end
