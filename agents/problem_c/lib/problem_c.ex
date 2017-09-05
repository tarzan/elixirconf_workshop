defmodule ProblemC do
  @moduledoc """
  ProblemC.
  """

  @doc """
  Stop a GenServer. Expects GenServer to stop with reason `reason` on receiving
  call `{:stop, reason}`. GenServer should reply with message `:ok`.
  """
  def stop(gen_server) do
    process = GenServer.whereis(gen_server)
    monitor = Process.monitor(process)

    GenServer.call(gen_server, {:stop, :normal}, :infinity)

    receive do
      {:DOWN, ^monitor, :process, _pid, _reason} -> :ok
    end
  end
end
