defmodule ProblemDTest do
  use ExUnit.Case
  doctest ProblemD

  setup do
    {:ok, pid} = ProblemD.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "Alice holds some of Bob's state" do
    assert Agent.get(:alice, &Map.get(&1, :ref)) == Agent.get(:bob, &(&1))
  end

  @tag :capture_log
  test "Alice holds some of Bob's state after Alice crashes" do
    Agent.stop(:alice, :crash)

    # wait for restart
    :timer.sleep(500)

    assert Agent.get(:alice, &Map.get(&1, :ref)) == Agent.get(:bob, &(&1))
  end

  @tag :capture_log
  test "Alice holds some of Bob's state after Bob crashes" do
    Agent.stop(:bob, :crash)

    # wait for restart
    :timer.sleep(500)

    assert Agent.get(:alice, &Map.get(&1, :ref)) == Agent.get(:bob, &(&1))
  end
end
