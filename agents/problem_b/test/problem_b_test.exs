defmodule ProblemBTest do
  use ExUnit.Case
  doctest ProblemB

  test "fetch a value from GenServer's map when key exists" do
    {:ok, server} = ProblemB.start_link(%{foo: :bar})
    assert ProblemB.fetch!(server, :foo) == :bar
  end

  test "fetch a value from GenServer's map when key does not exist" do
    {:ok, server} = ProblemB.start_link(%{foo: :bar})
    assert_raise KeyError, "key :buzz not found in: %{foo: :bar}",
      fn() -> ProblemB.fetch!(server, :buzz) end
  end
end
