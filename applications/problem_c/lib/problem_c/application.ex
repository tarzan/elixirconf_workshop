defmodule ProblemC.Application do
  @moduledoc """
  Use :rest_for_one at the top level because Starter must be restarted if any of the other processes crash.
  If one or more of the servers get into a bad state we need to refresh the state of the application to prevent catastrophic
  failure.
  """

  alias ProblemC.{Tracker, ServerSupervisor, Starter}

  use Application

  def start(_type, _args) do
    sup_opts = [strategy: :one_for_all, max_restarts: 0]
    supervisor = %{id: Supervisor,
                   start: {Supervisor, :start_link, [[Tracker, ServerSupervisor], sup_opts]},
                   type: :supervisor}
    Supervisor.start_link([supervisor, Starter], [strategy: :rest_for_one])
  end
end
