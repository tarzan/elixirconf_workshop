defmodule ProblemD do
  @moduledoc """
  After using Task.async/1 and swapping Task.await/2 and Task.yield/2, this exercise you build them. async/1 sets up the relationship with start_link/2 which links the process to the function init/2.
  The main difference, as illustrated in the last problem, between yield/2 and await/2 is that after the specified timeout, await/2 demonitors the process and calls exit/1. yield/2 however returns nil and doesn't demonitor.
  """

  @enforce_keys [:pid, :ref]
  defstruct [:pid, :ref]

  @doc """
  Start a task and await on the result, as `Task.async`.
  """
  def async(fun) do
    {:ok, pid} = Task.start_link(__MODULE__, :init, [self(), fun])
    ref = Process.monitor(pid)
    send(pid, {:go, self(), ref})
    %__MODULE__{pid: pid, ref: ref}
  end

  @doc false
  def init(parent, fun) do
   receive do
     {:go, ^parent, ref} ->
       send(parent, {ref, fun.()})
       exit(:normal)
    end
  end

  @doc """
  Await the result of a task, as `Task.await`
  """
  def await(%__MODULE__{ref: ref} = task, timeout) do
    receive do
      {^ref, result} ->
        Process.demonitor(ref, [:flush])
        result
      {:DOWN, ^ref, _, _, reason} ->
        exit({reason, {__MODULE__, :await, [task, timeout]}})
    after
      timeout ->
        Process.demonitor(ref, [:flush])
        exit({:timeout, {__MODULE__, :await, [task, timeout]}})
    end
  end

  @doc """
  Yield to wait the result of a task, as `Task.yield`.
  """
  def yield(%__MODULE__{ref: ref}, timeout) do
    receive do
      {^ref, result} ->
        Process.demonitor(ref, [:flush])
        {:ok, result}
      {:DOWN, ^ref, _, _, reason} ->
        {:exit, reason}
    after
      timeout ->
        nil
    end
  end
end
