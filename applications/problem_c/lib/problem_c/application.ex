defmodule ProblemC.Application do
  @moduledoc false

  alias ProblemC.{Tracker, ServerSupervisor, Starter}

  use Application

  def start(_type, _args) do
    Supervisor.start_link([Tracker, ServerSupervisor, Starter], [strategy: :one_for_one])
  end
end
