defmodule OnlineMock.DateTime do
  @moduledoc false

  @minute_in_seconds 60
  @hour_in_seconds 60 * @minute_in_seconds
  @day_in_seconds 24 * @hour_in_seconds

  def configure(value) do
    OnlineMock.State.put([__MODULE__], value)
    OnlineMock.PKI.config_change()
  end

  def utc_now() do
    case OnlineMock.State.get([__MODULE__]) do
      nil ->
        NaiveDateTime.utc_now()

      {:offset, offset} ->
        NaiveDateTime.utc_now() |> add(offset)

      datetime ->
        datetime
    end
  end

  def add(naive_datetime, {:second, seconds}) do
    NaiveDateTime.add(naive_datetime, seconds)
  end

  def add(naive_datetime, {:minute, minutes}) do
    NaiveDateTime.add(naive_datetime, @minute_in_seconds * minutes)
  end

  def add(naive_datetime, {:hour, hours}) do
    NaiveDateTime.add(naive_datetime, @hour_in_seconds * hours)
  end

  def add(naive_datetime, {:day, days}) do
    NaiveDateTime.add(naive_datetime, @day_in_seconds * days)
  end
end
