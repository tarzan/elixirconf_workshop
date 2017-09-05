defmodule ProblemB.Application do
  @moduledoc false

  alias ProblemB.{Server, TaskSupervisor}

  use Application

  def start(_type, _args) do
    Supervisor.start_link([Server, TaskSupervisor], [strategy: :one_for_all])
  end
end
