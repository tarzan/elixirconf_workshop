defmodule ProblemE do
  @moduledoc """
  ProblemE.
  """

  @doc """
  Start a Supervisor for Agents.
  """
  def start_link(opts \\ []) do
    Supervisor.start_link(__MODULE__, opts)
  end

  def init(opts) do
    {restart, opts} = Keyword.pop(opts, :restart, :temporary)
    {shutdown, opts} = Keyword.pop(opts, :shutdown, 5_000)

    child = %{id: Agent,
              start: {Agent, :start_link, []},
              restart: restart,
              shutdown: shutdown}

    Supervisor.init([child], [strategy: :simple_one_for_one] ++ opts)
  end

  @doc """
  Start an Agent with a fun.
  """
  def start_child(sup, fun, opts \\ []) do
    Supervisor.start_child(sup, [fun, opts])
  end

  @doc """
  Start an Agent with module, function and arguments.
  """
  def start_child(sup, mod, fun, args, opts \\ []) do
    Supervisor.start_child(sup, [mod, fun, args, opts])
  end
end
