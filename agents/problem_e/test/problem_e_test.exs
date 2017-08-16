defmodule ProblemETest do
  use ExUnit.Case
  doctest ProblemE

  test "explicitly start GenServer and increment by one" do
    ProblemE.start_link
    ProblemE.incr(:counter)

    assert ProblemE.pop(:counter) == 1
  end

  test "explicitly start GenServer, pop, increment and then pop to check that the counter has been incremented" do
    ProblemE.start_link
    assert ProblemE.pop(:counter) == 0
    ProblemE.incr(:counter)
    assert ProblemE.pop(:counter) == 1
  end

  test "without explicitly starting GenServer, pop/1 returns 0" do
    assert ProblemE.pop(:counter) == 0
  end
end
