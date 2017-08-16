defmodule ProblemBTest do
  use ExUnit.Case
  doctest ProblemB

  setup do
    {:ok, pid} = ProblemB.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "deposit, withdraw and retrieve balanace" do
    assert ProblemB.deposit(5) == 5
    assert ProblemB.withdraw(3) == 2
    assert ProblemB.balance() == 2
  end

  @tag :capture_log
  test "balance recovered after server crash" do
    assert ProblemB.deposit(7) == 7

    GenServer.stop(ProblemB.Server, :crash)

    :timer.sleep(500)

    assert ProblemB.withdraw(1) == 6
  end

  @tag :capture_log
  test "reset balance if agent gets bad state" do
    assert ProblemB.deposit(3) == 3

    assert Agent.update(ProblemB.State, fn(_) -> :BAD end)

    assert ProblemB.balance() == 3

    catch_exit(ProblemB.withdraw(5))

    :timer.sleep(500)

    assert ProblemB.deposit(1) == 1
    assert ProblemB.balance() == 1
  end
end
