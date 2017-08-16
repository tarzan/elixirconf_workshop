## See problem_b/application.ex
defmodule ProblemB do
  @moduledoc """
  ProblemB.
  """

  @doc """
  Run a function in another process.

  Returns `{:ok, result}` on success, otherwise `{:error, reason}`.
  """
  defdelegate run(fun), to: ProblemB.Server

  defmodule Server do
    @moduledoc false

    use GenServer, start: {__MODULE__, :start_link, []}

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def run(fun) do
      GenServer.call(__MODULE__, {:run, fun})
    end

    def init(_) do
      {:ok, %{}}
    end

    def handle_call({:run, fun}, from, state) do
      %Task{ref: ref} = ProblemB.TaskSupervisor.async_nolink(fun)
      {:noreply, Map.put(state, ref, from)}
    end

    def handle_info({ref, result}, state) do
      {from, state} = Map.pop(state, ref)
      GenServer.reply(from, {:ok, result})
      Process.demonitor(ref, [:flush])
      {:noreply, state}
    end
    def handle_info({:DOWN, ref, _, _, reason}, state) do
      {from, state} = Map.pop(state, ref)
      GenServer.reply(from, {:error, reason})
      {:noreply, state}
    end
  end

  defmodule TaskSupervisor do
    @moduledoc false

    def child_spec(opts) do
      %{id: __MODULE__,
        start: {__MODULE__, :start_link, [opts]},
        type: :supervisor}
    end

    def start_link(opts) do
      Task.Supervisor.start_link([name: __MODULE__] ++ opts)
    end

    def async_nolink(fun) do
      Task.Supervisor.async_nolink(__MODULE__, fun)
    end
  end
end
