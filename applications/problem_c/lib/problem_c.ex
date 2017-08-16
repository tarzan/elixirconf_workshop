## See problem_c/application.ex
defmodule ProblemC do
  @moduledoc """
  ProblemC.
  """

  defdelegate ping(name), to: ProblemC.Server

  defmodule Tracker do
    @moduledoc false

    use Agent, start: {__MODULE__, :start_link, []}

    def start_link() do
      Agent.start_link(fn() -> MapSet.new([:alice, :bob]) end, [name: __MODULE__])
    end

    def put(name) do
      Agent.update(__MODULE__, &MapSet.put(&1, name))
    end

    def delete(name) do
      Agent.update(__MODULE__, &MapSet.delete(&1, name))
    end

    def all() do
      Agent.get(__MODULE__, &Enum.to_list/1)
    end
  end

  defmodule Starter do
    @moduledoc false

    use GenServer, start: {__MODULE__, :start_link, []}

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def init(_) do
      for name <- Tracker.all() do
        case ProblemC.ServerSupervisor.start_child(name) do
          {:ok, _} ->
            :ok
          {:error, {:already_started, _}} ->
            :ok
        end
      end
      # don't enter loop!
      :ignore
    end
  end

  defmodule Server do
    @moduledoc false

    alias ProblemC.{Tracker, ServerSupervisor}

    use GenServer, restart: :transient

    def start_link(name) do
      GenServer.start_link(__MODULE__, name, [name: name])
    end

    def ping(name) do
      try do
        GenServer.call(name, :ping)
      catch
        :exit, {reason, _} when reason in [:noproc, :normal] ->
          start(name)
      end
    end

    defp start(name) do
      case ServerSupervisor.start_child(name) do
        {:ok, _} ->
          :pong
        {:error, {:already_started, _}} ->
          :pong
        {:error, _} ->
          :pang
      end
    end

    def init(:crash) do
      {:error, :crash}
    end
    def init(name) do
      Tracker.put(name)
      {:ok, name}
    end

    def handle_call(:ping, _, name) do
      {:reply, :pong, name}
    end

    def terminate(:normal, name) do
      Tracker.delete(name)
    end
    def terminate(_, _) do
      :ok
    end
  end

  defmodule ServerSupervisor do
    @moduledoc false

    def child_spec(opts) do
      %{id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]},
        type: :supervisor}
    end

    def start_link(opts) do
      server = Supervisor.child_spec(ProblemC.Server, [start: {ProblemC.Server, :start_link, []}])
      opts = [strategy: :simple_one_for_one, max_restarts: 1, name: __MODULE__] ++ opts
      Supervisor.start_link([server], opts)
    end

    def start_child(name) do
      Supervisor.start_child(__MODULE__, [name])
    end
  end
end
