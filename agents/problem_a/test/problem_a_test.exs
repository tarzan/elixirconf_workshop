defmodule ProblemATest do
  use ExUnit.Case
  doctest ProblemA

  test "fetch a value from Agent's map when key exists" do
    {:ok, agent} = ProblemA.start_link(%{foo: :bar})
    assert ProblemA.fetch!(agent, :foo) == :bar
  end

  test "fetch a value from Agent's map when key does not exist" do
    {:ok, agent} = ProblemA.start_link(%{foo: :bar})
    assert_raise KeyError, "key :buzz not found in: %{foo: :bar}",
      fn() -> ProblemA.fetch!(agent, :buzz) end
  end
end
