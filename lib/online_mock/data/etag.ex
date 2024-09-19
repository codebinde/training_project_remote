defmodule OnlineMock.Data.Etag do
  @moduledoc false

  def create_etag(data, opts \\ %{})

  def create_etag(data, %{use_time: true}) do
    {data_to_number(data), System.monotonic_time(:millisecond)}
    |> hash_data()
  end

  def create_etag(data, _opts) do
    data
    |> data_to_number()
    |> hash_data()
  end

  defp hash_data(data) do
    data
    |> :erlang.phash2()
    |> integer_to_quoted_str()
    |> Base.encode64()
  end

  defp data_to_number(data) when is_bitstring(data) do
    byte_size(data)
  end

  defp data_to_number(data) do
    :erlang.phash2(data)
  end

  defp integer_to_quoted_str(x) do
    <<?", Integer.to_string(x, 16)::binary, ?">>
  end
end
