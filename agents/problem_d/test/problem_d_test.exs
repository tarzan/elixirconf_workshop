defmodule ProblemDTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest ProblemD

  test "prints random numbers" do
    assert capture_io(fn ->
      ProblemD.start_link(1000)
      :timer.sleep(2000)
    end) =~ ~r"\d+"
  end

  test "prints timeout on request timeout" do
    assert capture_io(fn ->
      ProblemD.start_link(10)
      :timer.sleep(1000)
    end) =~ "request timeout"
  end
end
