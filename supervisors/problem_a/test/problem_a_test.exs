defmodule ProblemATest do
  use ExUnit.Case
  doctest ProblemA

  test "task runs and is restarted when killed" do
    starter = self()
    assert {:ok, pid} = ProblemA.start_link(fn() ->
      send(starter, {:task, self()})
      # sleep forever to keep process alive
      :timer.sleep(:infinity)
    end)
    assert is_pid(pid)

    assert_receive {:task, task}
    ref = Process.monitor(task)
    Process.exit(task, :kill)
    assert_receive {:DOWN, ^ref, _, _, :killed}

    assert_receive {:task, _}
  end

  @tag :capture_log
  test "task crashes twice and then gives up" do
    Process.flag(:trap_exit, true)
    starter = self()
    assert {:ok, sup} = ProblemA.start_link(fn() ->
      send(starter, {:task, self()})
      raise "good bye world!"
    end)

    assert_receive {:task, task1}

    assert_receive {:task, task2}
    refute Process.alive?(task1)

    assert_receive {:EXIT, ^sup, :shutdown}
    refute Process.alive?(task2)

    refute_received {:task, _}
  end

  test "test stops normally and is not restarted" do
    Process.flag(:trap_exit, true)
    starter = self()
    ProblemA.start_link(fn() ->
      Process.link(starter)
      send(starter, {:task, self()})
      exit(:normal)
    end)

    assert_receive {:task, task}
    assert_receive {:EXIT, ^task, :normal}

    refute_receive {:task, _}
  end
end
