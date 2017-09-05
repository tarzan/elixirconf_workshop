defmodule ProblemA do
  @moduledoc """
  Set up a supervisor and monitor it using the new Supervisor ChildTask. We use :one_for_one since we only care about restarting that child.
  """

  defmodule ChildTask do
    use Task, restart: :transient

    defdelegate start_link(fun), to: Task
  end

  @doc """
  Start a task that is run again if it crashes
  """
  def start_link(fun) do
   Supervisor.start_link([{ChildTask, fun}], [strategy: :one_for_one, max_restarts: 1])
  end
end
