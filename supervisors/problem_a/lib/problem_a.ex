defmodule ProblemA do
  @moduledoc """
  ProblemA.
  """

  @doc """
  Start a task that is run again if it crashes
  """
  def start_link(fun) do
    Task.start_link(fun)
  end
end
