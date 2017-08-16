defmodule ProblemD do
  @moduledoc """
  ProblemD.
  """

  alias __MODULE__.{Alice, Bob}

  @doc """
  Start the Agents.
  """
  def start_link() do
    strategy = :one_for_one

    ## Do not change code below

    children = [Alice, Bob]
    Supervisor.start_link(children, [strategy: strategy, max_restarts: 1])
  end

  defmodule Alice do

    use Agent, [id: :alice, start: {__MODULE__, :start_link, []}]

    def start_link() do
      Agent.start_link(&Map.new/0, [name: :alice])
    end
  end

  defmodule Bob do

    use Agent, [id: :bob, start: {__MODULE__, :start_link, []}]

    def start_link() do
      Agent.start_link(&init/0, [name: :bob])
    end

    defp init() do
      ref = make_ref()
      Agent.update(:alice, fn(map) ->
        Map.update(map, :ref, ref, fn(val) -> raise "ref is #{inspect val}" end)
      end)
      ref
    end
  end
end
