defmodule ProblemATest do
  use ExUnit.Case
  doctest ProblemA

  alias ProblemA.{Alice, Bob}

  setup_all do
    Application.stop(:problem_a)
    on_exit(fn() -> Application.start(:problem_a) end)
  end

  setup do
    :ok = Application.start(:problem_a)
    on_exit(fn() -> Application.stop(:problem_a) end)
  end

  test "Alice learns Elixir" do
    assert Alice.learn(:elixir) == :ok
    assert Alice.languages() == [:elixir]
  end

  test "Bob learns Erlang, crashes and still knows Erlang" do
    assert Bob.learn(:erlang) == :ok
    Agent.stop(Bob, :crash)

    # Wait for Bob to restart
    :timer.sleep(100)

    assert Bob.languages() == [:erlang]
  end

  test "Bob learns Erlang, Alice crashes and Bob still knows Erlang" do
    assert Bob.learn(:erlang) == :ok
    Agent.stop(Alice, :crash)

    # Wait for Alice to restart
    :timer.sleep(100)

    assert Alice.learn(:elixir) == :ok
    assert Bob.languages() == [:erlang]
  end

  test "Alice learns Elixir, Alice crashes and Alice still knows Elixir" do
    assert Alice.learn(:elixir) == :ok
    Agent.stop(Alice, :crash)

    # Wait for Alice to restart
    :timer.sleep(100)

    assert Alice.languages() == [:elixir]
  end

  test "Alice tries to learn Elixir after corrupt Data and eventually does" do
    ProblemA.Data.put(:alice, :bad)
    Agent.stop(Alice, :crash)
    # Wait for Alice to restart
    :timer.sleep(100)
    catch_exit(Alice.learn(:elixir))
    # Wait for Alice to restart
    :timer.sleep(100)
    catch_exit(Alice.learn(:elixir))
    # Wait for Alice to restart
    :timer.sleep(100)
    catch_exit(Alice.learn(:elixir))
    # Wait for Alice to restart
    :timer.sleep(100)

    assert Alice.languages() == []
  end
end
