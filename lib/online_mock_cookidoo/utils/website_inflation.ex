defmodule OnlineMockCookidoo.WebsiteInflation do
  @moduledoc false

  @key __MODULE__
  @one_kb_text for(
                 _ <- 1..1000,
                 into: "",
                 do: <<Enum.random(~c"01234567890qwertzuiopasdfghjklyxcvbnm")>>
               ) <> "\n"

  def get_inflation_string() do
    default = Application.get_env(:online_mock, :website_inflation_kb)

    case OnlineMock.State.get([@key, :inflation_kb], default) do
      inflation_kb when is_integer(inflation_kb) and inflation_kb >= 0 ->
        String.duplicate(@one_kb_text, inflation_kb)

      _ ->
        ""
    end
  end

  def set_inflation_kb(inflation_kb) do
    OnlineMock.State.put([Access.key(@key, %{}), :inflation_kb], inflation_kb)
  end
end
