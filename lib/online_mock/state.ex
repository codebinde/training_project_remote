defmodule OnlineMock.State do
  @moduledoc false

  use Agent

  @name __MODULE__

  def start_link(initial_state \\ %{}) do
    Agent.start_link(fn -> initial_state end, name: @name)
  end

  def get(path) do
    Agent.get(@name, fn state -> get_in(state, path) end)
  end

  def get(path, default) do
    case Agent.get(@name, fn state -> get_in(state, path) end) do
      nil -> default
      value -> value
    end
  end

  def put(path, value) do
    Agent.update(@name, fn state -> put_in(state, path, value) end)
  end

  def update(path, fun) do
    Agent.update(@name, fn state -> update_in(state, path, fun) end)
  end

  def get_and_update(path, fun) do
    Agent.get_and_update(@name, fn state -> {get_in(state, path), update_in(state, path, fun)} end)
  end

  def pop(path) do
    Agent.get_and_update(@name, fn state -> pop_in(state, path) end)
  end
end
