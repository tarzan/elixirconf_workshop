defmodule ProblemC do
  @moduledoc """
  ProblemC.
  """

  @doc """
  Stop a GenServer. Expects GenServer to stop with reason `reason` on receiving
  call `{:stop, reason}`. GenServer should reply with message `:ok`.
  """
  def stop(gen_server) do
    GenServer.call(gen_server, {:stop, :normal}, :infinity)
  end
end
