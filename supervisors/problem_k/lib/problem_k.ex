defmodule ProblemK do
  @moduledoc """
  We must trap exits so that we can restart the task if we receive its exit signal. Also we need to ensure
  the task is shutdown before the supervisor exits so that we guarantee no processes are temporarily orphaned.
  """

  @doc """
  Write a Task supervising process that starts a single task with
  `Task.start_link(fun)` and restarts it if it exits.
  """
  def start_link(fun) do
    GenServer.start_link(__MODULE__, fun)
  end

  def init(fun) do
    Process.flag(:trap_exit, true)
    {:ok, pid} = Task.start_link(fun)
    {:ok, {pid, fun}}
  end

  def handle_info({:EXIT, pid, _}, {pid, fun}) do
    {:ok, new_pid} = Task.start_link(fun)
    {:noreply, {new_pid, fun}}
  end

  def handle_info({:EXIT, _, _}, state) do
    {:noreply, state}
  end

  def terminate(_, {pid, _}) do
    Process.exit(pid, :shutdown)
    receive do
      {:EXIT, ^pid, _} ->
        :ok
    end
  end
end
