defmodule ProblemL do
  @moduledoc """
  The important takeaway is the order of operations: start_link, monitor, and then perform action. The task has to wait
  for the caller to set up the monitor. If the task crashed before the link or the monitor, the caller might get a `:noproc` reason
  and not know why it crashed.
  """

  @enforce_keys [:pid, :ref]
  defstruct [:pid, :ref]

  @doc """
  Start a supervising process for tasks to run with async/2.

  The only supported option is [shutdown: timeout | :brutal_kill], where
  `timeout` will try to shutdown the tasks for the timeout and then kill, and
  `:brutal_kill` will kill the tasks straight away when terminating the
  supervisor.
  """
  def start_link(opts \\ []) do
    task_opts = [restart: :temporary, modules: [__MODULE__]] ++ Keyword.drop(opts, [:id, :start])
    task = Supervisor.child_spec(%{id: Task, start: {Task, :start_link, [__MODULE__, :start_task]}},
                                 task_opts)
    Supervisor.start_link([task], [strategy: :simple_one_for_one])
  end

  @doc """
  Start a task under a supervisor and await on the result, as `Task.async`.
  """
  def async(sup, fun) do
    tag = make_ref()
    {:ok, pid} = Supervisor.start_child(sup, [[self(), tag]])
    Process.link(pid)
    ref = Process.monitor(pid)
    send(pid, {:go, tag, ref, fun})
    %ProblemL{pid: pid, ref: ref}
  end


  @doc """
  Await the result of a task, as `Task.await`
  """
  def await(%ProblemL{ref: ref} = task, timeout) do
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

  @doc false
  def start_task(caller, tag) do
    mon = Process.monitor(caller)
    receive do
      {:go, ^tag, ref, fun} ->
        Process.demonitor(mon, [:flush])
        send(caller, {ref, fun.()})
      {:DOWN, ^mon, _, _, reason} ->
        exit({:shutdown, reason})
    end
  end
end
