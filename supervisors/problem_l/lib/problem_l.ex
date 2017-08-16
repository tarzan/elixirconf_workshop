defmodule ProblemL do
  @moduledoc """
  ProblemL.
  """

  @enforce_keys [:pid, :ref]
  defstruct [:pid, :ref]

  @doc """
  Start a supervising process for tasks to run with async/2.

  The only supported option is [shutdown: timeout | :brutal_kill], where
  `timeout` will try to shutdown the tasks for the timeout and then kill, and
  `:brutal_kill` will kill the tasks straight away when terminating the
  supervisor.
  """
  def start_link(opts \\ [])

  @doc """
  Start a task under a supervisor and await on the result, as `Task.async`.
  """
  def async(sup, fun)

  @doc """
  Await the result of a task, as `Task.await`
  """
  def await(task, timeout)
end
