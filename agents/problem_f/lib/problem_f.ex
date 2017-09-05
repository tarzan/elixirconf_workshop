defmodule ProblemF do
  @moduledoc """
  In this problem, we need to first find the pid of the GenServer so we monitor and cast to the same process. The monitor ensures we know if the GenServer crashes before we receive a response. When using this
  technique, we will need to manually demonitor (with flush) so we don't leak the monitor.
  """
  use GenServer

  @doc """
  Pulls a value off
  """
  def pop() do
    pid = GenServer.whereis(__MODULE__)
    ref = Process.monitor(pid)
    GenServer.cast(pid, {:pop, self(), ref})
    ref
  end

  @doc """
  Appends a value
  """
  def push(value) do
    GenServer.call(__MODULE__, {:push, value})
  end

  # only change code above

  def start_link() do
    GenServer.start_link(__MODULE__, {[], []}, [name: __MODULE__])
  end

  def handle_cast({:pop, pid, ref}, {[], waiting}) do
    {:noreply, {[], waiting ++ [{pid, ref}]}}
  end
  def handle_cast({:pop, pid, ref}, {[value | stack], []}) do
    send(pid, {ref, value})
    {:noreply, {stack, []}}
  end

  def handle_call({:push, value}, _from, {stack, []}) do
    {:reply, :ok, [value|stack], []}
  end
  def handle_call({:push, value}, _from, {stack, [next | waiting]}) do
    {pid, ref} = next
    send(pid, {ref, value})
    {:reply, :ok, {stack, waiting}}
  end
end
