defmodule ProblemA.Application do
  @moduledoc false

  alias ProblemA.{Alice, Bob, Data}

  use Application

  def start(_type, _args) do
    Supervisor.start_link([Data, Alice, Bob], [strategy: :one_for_one])
  end
end
