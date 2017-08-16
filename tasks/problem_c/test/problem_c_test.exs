defmodule ProblemCTest do
  use ExUnit.Case
  doctest ProblemC

  test "successfully returns response" do
    assert {:ok, _result} = ProblemC.get(5000)
  end

  test "gracefully handle external request timeout" do
    assert ProblemC.get(10) == :request_timeout
  end
end
