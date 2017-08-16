defmodule ProblemE do
  @moduledoc """
  ProblemE.
  """

  @doc """
  Start a Supervisor for Agents.
  """
  def start_link(opts \\ [])

  @doc """
  Initialize the Supervisor
  """
  def init(opts)

  @doc """
  Start an Agent with a fun.
  """
  def start_child(sup, fun, opts \\ [])

  @doc """
  Start an Agent with module, function and arguments.
  """
  def start_child(sup, mod, fun, args, opts \\ [])
end
