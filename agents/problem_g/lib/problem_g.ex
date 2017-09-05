defmodule ProblemG do
  @moduledoc """
  ProblemG.
  """

  @doc """
  Start task.
  """
  def start_link() do
    Task.start_link(__MODULE__, :loop, [])
  end

  # Only change call/3 and reply/2; use the message structure defined in loop/0.

  @doc """
  Call task.
  """
  def call(task, request, timeout) do
    pid = GenServer.whereis(task)
    ref = Process.monitor(pid)

    send(pid, {__MODULE__, {self(), ref}, request})

    receive do
      {^ref, result} ->
        Process.demonitor(ref, [:flush])
        result
      {:DOWN, ^ref, _, _, :noconnect} ->
        reason = {:nodedown, node(pid)}
        exit({reason, {__MODULE__, :call, [task, request, timeout]}})
      {:DOWN, ^ref, _, _, reason} ->
        exit({reason, {__MODULE__}})
      after
        timeout ->
          Process.demonitor(ref, [:flush])
          exit({:timeout, {__MODULE__, :call, [task, request, timeout]}})
    end
  end

  @doc """
  Reply to call
  """
  def reply({pid, ref}, response), do: send(pid, {ref, response})


  @doc false
  def loop() do
    receive do
      {__MODULE__, from, :ping} ->
        __MODULE__.reply(from, :pong)
        loop()
      {__MODULE__, _, :ignore} ->
        loop()
      {__MODULE__, _, :stop} ->
        exit(:stop)
    end
  end
end
