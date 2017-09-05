defmodule ProblemC do
  @moduledoc """
  This is similar to the task problem where we stopped the process. The difference is that we're using the GenServer behaviour and `call/3` which hides the process-level nitty gritty.
  The `:DOWN` response is the same which should give you insight into the relationship between the two.
  """

  @doc """
  Stop a GenServer. Expects GenServer to stop with reason `reason` on receiving
  call `{:stop, reason}`. GenServer should reply with message `:ok`.
  """
  def stop(gen_server) do
    ref = Process.monitor(gen_server)
    GenServer.call(gen_server, {:stop, :normal}, :infinity)
    receive do
      {:DOWN, ^ref, _, _, _} ->
        :ok
    end
  end
end
