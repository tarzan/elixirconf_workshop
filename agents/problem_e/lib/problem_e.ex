defmodule ProblemE do
  @moduledoc """
  In this problem, we want to automatically start the GenServer. If we get a `:noproc` exit reason, the GenServer isn't started and
  we can safely start it. If we get a `:normal` exit reason, the GenServer didn't handle the call and we can safely start it and repeat the call.
  """
  use GenServer

  def pop(key) do
    ensure_started(fn -> GenServer.call(__MODULE__, {:pop, key}) end)
  end

  def incr(key) do
    ensure_started(fn -> GenServer.call(__MODULE__, {:incr, key}) end)
  end

  defp ensure_started(fun) do
    try do
      fun.()
    catch
      :exit, {normal, {GenServer, :call, [__MODULE__ | _]}} when normal in [:normal, :noproc] ->
        start_retry(fun)
    end
  end

  defp start_retry(fun) do
    case start_link() do
      {:ok, _pid} ->
        ensure_started(fun);
      {:error, {:already_started, _pid}} ->
        ensure_started(fun);
    end
  end

  # only change code above

  def start_link() do
    GenServer.start_link(__MODULE__, %{}, [name: __MODULE__])
  end

  def handle_call({:incr, key}, _from,  state) do
    {:reply, :ok, Map.update(state, key, 1, &(&1 + 1))}
  end

  def handle_call({:pop, key}, _from, state) do
    {val, state} = Map.pop(state, key, 0)
    if state == %{} do
      {:stop, :normal, val, state}
    else
      {:reply, val, state}
    end
  end
end
