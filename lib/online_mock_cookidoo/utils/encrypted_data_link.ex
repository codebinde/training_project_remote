defmodule OnlineMockCookidoo.EncryptedDataLink do
  @moduledoc false

  def create_descriptor(name, href, tag) do
    %{
      "algorithm" => "AES-256-GCM",
      "authTag" => tag,
      "iv" => Base.encode64(Application.fetch_env!(:online_mock, :enc_ivec)),
      "key" => Base.encode64(Application.fetch_env!(:online_mock, :enc_key)),
      "_links" => %{
        name => %{"href" => href, "type" => "application/octet-stream"}
      }
    }
  end
end
