defmodule ProblemLTest do
  use ExUnit.Case
  doctest ProblemL

  test "async uses a monitor" do
    {:ok, sup} = ProblemL.start_link([])
    %ProblemL{ref: ref} = ProblemL.async(sup, fn() -> 1 + 1 end)
    assert_receive {^ref, 2}
    assert_receive {:DOWN, ^ref, :process, _, :normal}
  end

  test "async uses a link" do
    Process.flag(:trap_exit, true)
    {:ok, sup} = ProblemL.start_link([])
    assert %ProblemL{ref: ref, pid: pid} = ProblemL.async(sup, fn() -> 1 + 1 end)

    assert_receive {^ref, 2}
    assert_receive {:EXIT, ^pid, :normal}
  end

  test "await returns result" do
    {:ok, sup} = ProblemL.start_link([])
    task = ProblemL.async(sup, fn() -> 1 + 1 end)
    assert ProblemL.await(task, 5000) == 2
  end

  test "await flushes monitor on result" do
    {:ok, sup} = ProblemL.start_link([])
    task = ProblemL.async(sup, fn() -> 1 + 1 end)
    assert %ProblemL{ref: ref} = task
    assert ProblemL.await(task, 5000) == 2

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  @tag :capture_log
  test "await exits on exception" do
    Process.flag(:trap_exit, true)
    {:ok, sup} = ProblemL.start_link([])
    task = ProblemL.async(sup, fn() -> raise "oops" end)
    assert {{%RuntimeError{message: "oops"}, [_|_]},
            {ProblemL, :await, [^task, 123]}} =
      catch_exit(ProblemL.await(task, 123))
  end

  test "await exits on timeout" do
    {:ok, sup} = ProblemL.start_link([])
    task = ProblemL.async(sup, fn() -> :timer.sleep(:infinity) end)
    assert {:timeout, {ProblemL, :await, [^task, 123]}} =
      catch_exit(ProblemL.await(task, 123))
  end

  test "await flushes monitor on timeout" do
    {:ok, sup} = ProblemL.start_link([])
    task = ProblemL.async(sup, fn() -> :timer.sleep(:infinity) end)
    assert %ProblemL{ref: ref} = task
    assert catch_exit(ProblemL.await(task, 123))

    refute Process.demonitor(ref, [:info])
    refute_received {:DOWN, ^ref, _, _, _}
  end

  test "supports Supervisor.which_children" do
    {:ok, sup} = ProblemL.start_link([])
    fun = fn() -> :timer.sleep(:infinity) end
    %ProblemL{pid: pid} = ProblemL.async(sup, fun)
    assert Supervisor.which_children(sup) ==
      [{:undefined, pid, :worker, [ProblemL]}]
  end

  test "tasks are shut down before exit" do
    Process.flag(:trap_exit, true)
    {:ok, sup} = ProblemL.start_link([])
    fun = fn() -> :timer.sleep(:infinity) end
    %ProblemL{pid: pid} = ProblemL.async(sup, fun)

    Process.exit(sup, :shutdown)

    assert_receive {:EXIT, ^sup, :shutdown}
    assert_received {:EXIT, ^pid, :shutdown}
  end

  test "[shutdown: :brutal_kill] kills children on shutdown" do
    Process.flag(:trap_exit, true)
    {:ok, sup} = ProblemL.start_link([shutdown: :brutal_kill])
    fun =
      fn() ->
        Process.flag(:trap_exit, true)
        :timer.sleep(:infinity)
      end
    %ProblemL{pid: pid} = ProblemL.async(sup, fun)

    Process.exit(sup, :shutdown)

    assert_receive {:EXIT, ^sup, :shutdown}
    assert_received {:EXIT, ^pid, :killed}
  end
end
