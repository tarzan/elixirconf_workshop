defmodule ProblemB.Application do
  @moduledoc false

  alias ProblemB.{Server, TaskSupervisor}

  use Application

  def start(_type, _args) do
    Supervisor.start_link([TaskSupervisor, Server], [strategy: :one_for_one])
  end
end
