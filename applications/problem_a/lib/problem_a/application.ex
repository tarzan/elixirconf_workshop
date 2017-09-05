defmodule ProblemA.Application do
  @moduledoc """
  Split the state and the logic into separate levels in the supervision tree. This isolates the state data from crashes in other parts of the
  application. However, if the state data is corrupted or the rest of the application crashes with too much intensity, we refresh the state and the
  rest of the application. This creates two error kernels in the application and helps to prevent catastrophic failure.
  """

  alias ProblemA.{Alice, Bob, Data}
  use Application

  def start(_type, _args) do
    supervisor = %{id: Supervisor,
                   start: {Supervisor, :start_link, [[Alice, Bob], [strategy: :one_for_one]]},
                   type: :supervisor}
    Supervisor.start_link([Data, supervisor], [strategy: :one_for_all])
  end
end
