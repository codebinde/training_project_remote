defmodule OnlineMock.LockHandle do
  @moduledoc false

  use GenServer

  @name __MODULE__

  ## Interface

  def await_unlock(token) do
    GenServer.call(@name, {:await, token}, :infinity)
  end

  def unlock(token) do
    GenServer.call(@name, {:unlock, token})
  end

  def lock(token) do
    GenServer.call(@name, {:lock, token})
  end

  def start_link([]) do
    GenServer.start_link(__MODULE__, [], name: @name)
  end

  ## Callbacks

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:await, token}, from, state) do
    case state do
      %{^token => waiting_callers} ->
        # append to list of waiting callers
        {:noreply, %{state | token => [from | waiting_callers]}}

      _ ->
        # no lock, so reply immediately to caller
        {:reply, :ok, state}
    end
  end

  @impl GenServer
  def handle_call({:unlock, token}, _from, state) do
    case state do
      %{^token => waiting_callers} ->
        # respond to all waiting callers
        for caller <- waiting_callers, do: GenServer.reply(caller, :ok)
        {:reply, :ok, Map.delete(state, token)}

      _ ->
        # Lock is non-existent
        {:reply, :ok, state}
    end
  end

  @impl GenServer
  def handle_call({:lock, token}, _from, state) do
    case state do
      %{^token => _} ->
        # Lock is already in place
        {:reply, :ok, state}

      _ ->
        # Create new lock
        {:reply, :ok, Map.put(state, token, [])}
    end
  end
end
