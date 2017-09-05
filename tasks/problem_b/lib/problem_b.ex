defmodule ProblemB do
  @moduledoc """
  Passing in the pid of the process that you want to stop allows you you to monitor and send a message of `:stop` to the process you want to stop. Finally, pattern matching on the `:DOWN` message returns `:ok` signalling that
  the process has stopped. Note that the variable monitor is pinned (^) because it's the unique `:DOWN` for that process.
  """

  @doc """
  Starts the Task
  """
  def start() do
    Task.start(fn() ->
      receive do
        :stop ->
          :timer.sleep(1000)
          exit(:shutdown)
      end
    end)
  end

  @doc """
  Stop the process.
  """
  def stop(pid) do
    monitor = Process.monitor(pid)
    send(pid, :stop)
    receive do
      {:DOWN, ^monitor, _, _, _} -> :ok
    end
  end
end
