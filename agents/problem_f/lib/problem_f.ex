defmodule ProblemF do
  @moduledoc """
  ProblemF
  """
  use GenServer

  @doc """
  Pulls a value off
  """
  def pop() do
    ref = make_ref()
    GenServer.cast(__MODULE__, {:pop, self(), ref})
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
