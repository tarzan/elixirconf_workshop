defmodule ProblemFTest do
  use ExUnit.Case
  doctest ProblemF

  test "pop sends back result :foo asynchronously" do
    ProblemF.start_link
    ref = ProblemF.pop
    ProblemF.push(:foo)
    assert_receive {^ref, :foo}
  end

  test "pop monitors and receives :DOWN" do
    ProblemF.start_link
    ref = ProblemF.pop
    GenServer.stop(ProblemF)
    assert_receive {:DOWN, ^ref, _, _, :normal}
  end
end
