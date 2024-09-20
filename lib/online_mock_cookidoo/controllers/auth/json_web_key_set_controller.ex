defmodule OnlineMockCookidoo.Auth.JSONWebKeySetController do
  @moduledoc false

  use OnlineMockCookidoo, :controller

  def show(conn, _params) do
    keys =
      for key <- [:rsa, :ecdsa] do
        {_, jwk} =
          :code.priv_dir(:online_mock)
          |> Path.join(get_public_key(key))
          |> JOSE.JWK.from_pem_file()
          |> JOSE.JWK.to_public_map()

        case key do
          :rsa -> jwk |> Map.put("kid", get_key_id(key)) |> Map.put("x5c", get_x5c_claim())
          _ -> jwk |> Map.put("kid", get_key_id(key))
        end
      end

    json(conn, %{keys: keys})
  end

  defp get_public_key(key) do
    case key do
      :rsa -> "keys/#{get_rsa_key()}.key"
      :ecdsa -> "keys/#{get_ecdsa_key()}.key"
    end
  end

  defp get_key_id(key) do
    case key do
      :rsa -> get_rsa_key_id()
      :ecdsa -> get_ecdsa_key_id()
    end
  end

  defp get_x5c_claim do
    for cert <- get_cert_chain(get_rsa_key()) do
      {:Certificate, cert_der} = OnlineMock.PKI.lookup_cert(cert, :der)
      format_cert(cert_der)
    end
  end

  defp get_cert_chain(:vorwerk_intermediate), do: [:vorwerk_intermediate]

  defp get_cert_chain(:vorwerk_issuing),
    do: [:vorwerk_issuing] ++ get_cert_chain(:vorwerk_intermediate)

  defp get_cert_chain(name), do: [name] ++ get_cert_chain(:vorwerk_issuing)

  defp format_cert(cert) do
    {:Certificate, cert, :not_encrypted}
    |> List.wrap()
    |> :public_key.pem_encode()
    |> String.split("\n", trim: true)
    |> Enum.slice(1..-2//1)
    |> Enum.join()
  end

  defp get_ecdsa_key do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :key_cycle_ecdsa]) do
      nil -> :token_signing_ecdsa
      key -> key
    end
  end

  defp get_ecdsa_key_id do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :key_cycle_ecdsa]) do
      nil -> "ES256 Key ID"
      key when is_atom(key) and not is_nil(key) -> "New ES256 Key ID"
    end
  end

  defp get_rsa_key do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :key_cycle_rsa]) do
      nil -> :token_signing_rsa
      key -> key
    end
  end

  defp get_rsa_key_id do
    case OnlineMock.State.get([OnlineMockCookidoo.Auth.Token, :key_cycle_rsa]) do
      nil -> "RS256 Key ID"
      key when is_atom(key) and not is_nil(key) -> "New RS256 Key ID"
    end
  end
end
