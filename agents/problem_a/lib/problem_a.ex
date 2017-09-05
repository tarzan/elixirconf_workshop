defmodule ProblemA do
  @moduledoc """
  In this problem, the goal is to extract a value from a map. There are two cases to handle; either the key and value exist or they don't. As such, use the try/rescue/else construction to get the value. If it doesn't exist, rescue
  with the KeyError exception and return an `{:error, exception}` since we're dealing with maps. If it does exist, return the standard `{:ok, value}`. Finally, pattern match on the result of the extraction attempt. Since fetch!/2 is a bang function
  we only return the value or the exception.
  """

  @doc """
  Start when the argument is a map
  """
  def start_link(map) when is_map(map) do
    Agent.start_link(fn() -> map end)
  end

  @doc """
  Fetch a value from the agent.
  """
  def fetch!(agent, key) do
    res = Agent.get(agent, fn(state) ->
      try do
        Map.fetch!(state, key)
      rescue
        ex in KeyError ->
          {:error, ex}
      else
        value ->
          {:ok, value}
      end
    end)
    case res do
      {:ok, value} -> value
      {:error, ex} -> raise ex
    end
  end
end
