defmodule ProblemG do
  @moduledoc """
  The Client depends on the Server so the relationship is :rest_for_one with the Server started before the Client.
  """

  alias __MODULE__.{Server, Client}

  @doc """
  Start the GenServers.
  """
  def start_link() do
    strategy = :rest_for_one

    ## Do not change code below

    Supervisor.start_link([Server, Client], [strategy: strategy, max_restarts: 1])
  end

  defdelegate subscribe(), to: Server
  defdelegate unsubscribe(ref), to: Server

  defmodule Server do
    @moduledoc false

    use GenServer, start: {__MODULE__, :start_link, []}

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def subscribe(), do: GenServer.call(__MODULE__, {:subscribe, self()})

    def unsubscribe(ref), do: GenServer.call(__MODULE__, {:unsubscribe, ref})

    def init(_) do
      :millisecond
      |> System.monotonic_time()
      |> trigger()
      {:ok, %{}}
    end

    def handle_call({:subscribe, pid}, _, state) do
      ref = Process.monitor(pid)
      {:reply, ref, Map.put(state, ref, pid)}
    end

    def handle_call({:unsubscribe, ref}, _, state) do
      {pid, state} = Map.pop(state, ref, :error)
      case pid do
        pid when is_pid(pid) ->
          Process.demonitor(ref, [:flush])
          {:reply, :ok, state}
        :error ->
          {:reply, :error, state}
      end
    end

    def handle_info({:tick, now, counter}, state) do
      for {ref, pid} <- state, do: send(pid, {:tick, ref, counter})
      trigger(now, counter)
      {:noreply, state}
    end
    def handle_info({:DOWN, ref, _, _, _}, state) do
      {:noreply, Map.delete(state, ref)}
    end

    defp trigger(now, counter \\ 0) do
      next = now + 10
      Process.send_after(self(), {:tick, next, counter+1}, next, [abs: true])
      :ok
    end
  end

  defmodule Client do
    @moduledoc false

    use GenServer, start: {__MODULE__, :start_link, []}
    alias ProblemG.Server

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def init(_) do
      ref = Server.subscribe()
      {:ok, ref}
    end

    def handle_info({:tick, ref, _}, ref) do
      {:noreply, ref}
    end
  end
end
