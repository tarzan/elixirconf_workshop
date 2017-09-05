defmodule ProblemA.Application do
  @moduledoc false

  alias ProblemA.{Alice, Bob, Data}

  use Application

  def start(_type, _args) do
    supervisor = %{id: Supervisor,
                   start: { Supervisor, :start_link,
                            [[Alice, Bob], [strategy: :one_for_one]] },
                   type: :supervisor}

    Supervisor.start_link([Data, supervisor], [strategy: :one_for_all])
  end
end
