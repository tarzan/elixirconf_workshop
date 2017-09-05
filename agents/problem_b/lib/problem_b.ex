defmodule ProblemB do
  @moduledoc """
  ProblemB.
  """

  use GenServer

  @doc """
  Start GenServer with map as state.
  """
  def start_link(map) when is_map(map) do
    GenServer.start_link(__MODULE__, map)
  end

  @doc """
  Fetch a value from the server.
  """
  def fetch!(server, key) do
    case GenServer.call(server, {:fetch!, key}) do
      {:ok, value} -> value
      {:error, exception} -> raise exception
    end
  end

  @doc false
  def init(map) do
    {:ok, map}
  end

  @doc false
  def handle_call({:fetch!, key}, _, state) do
    {:reply, fetch(state, key), state}
  end

  defp fetch(state, key) do
    try do
      Map.fetch! state, key
    rescue
      exception in [KeyError] ->
        {:error, exception}
    else
      value ->
        {:ok, value}
    end
  end
end
