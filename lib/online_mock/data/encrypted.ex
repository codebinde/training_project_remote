defmodule OnlineMock.Data.Encrypted do
  def encrypted(content) do
    ivec = Application.fetch_env!(:online_mock, :enc_ivec)
    key = Application.fetch_env!(:online_mock, :enc_key)
    # block_encrypt
    {enc_data, auth_tag} =
      :crypto.crypto_one_time_aead(
        :aes_256_gcm,
        key,
        ivec,
        content,
        "",
        true
      )

    OnlineMock.Data.into_creator_tuple(
      enc_data,
      %{authTag: Base.encode64(auth_tag)}
    )
  end
end
