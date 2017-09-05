defmodule ProblemA do
  @moduledoc """
  ProblemA.
  """
  defmodule ChildTask do
    use Task, restart: :transient

    def start_link(fun), do: Task.start_link(fun)
  end
  @doc """
  Start a task that is run again if it crashes
  """
  def start_link(fun) do
    Supervisor.start_link([{ChildTask, fun}],
                          [strategy: :one_for_one, max_restarts: 1])
  end
end
