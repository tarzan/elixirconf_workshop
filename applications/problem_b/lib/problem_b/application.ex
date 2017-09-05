defmodule ProblemB.Application do
  @moduledoc """
  A :one_for_all strategy is used because the children of the task supervisor should exit if the server crashes. TaskSupervisor needs to be started
  before the server because the server is calling the TaskSupervisor.
  """

  alias ProblemB.{Server, TaskSupervisor}

  use Application

  def start(_type, _args) do
    Supervisor.start_link([TaskSupervisor, Server], [strategy: :one_for_all])
  end
end
