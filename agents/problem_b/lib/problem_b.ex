defmodule ProblemB do
  @moduledoc """
  This problem is conceptually similar to the last one except that GenServer is used. As such, we start with `start_link/1` passing in the map which then calls `init/1` to initialize the server. After that, the logic is the same except that
  that we need to implement the synchronous handle_call/3 function. handle_call/3 is a blocking call and it returns a 2, 3 or 4-tuple. In this case, it returns `{:reply, resp, state}` to send the response to the caller. Again, the caller pattern matches
  on the response and raises on error.
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
      {:ok, val} -> val
      {:error, ex} -> raise ex
    end
  end

  @doc false
  def init(map) do
    {:ok, map}
  end

  @doc false
  def handle_call({:fetch!, key}, _, state) do
    resp =
    try do
      Map.fetch!(state, key)
    rescue
      ex in KeyError ->
        {:error, ex}
    else
      value ->
        {:ok, value}
    end
    {:reply, resp, state}
  end
end
