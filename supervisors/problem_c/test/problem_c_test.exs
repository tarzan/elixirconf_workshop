defmodule ProblemCTest do
  use ExUnit.Case
  doctest ProblemC

  setup_all do
    ProblemC.start_link()
    :ok
  end

  setup do
    for name <- [:alice, :bob] do
      ProblemC.forget(name)
    end
    :ok
  end

  test "Alice learns Elixir" do
    assert ProblemC.learn(:alice, :elixir) == :ok
    assert ProblemC.languages(:alice) == [:elixir]
  end

  @tag :capture_log
  test "Bob learns Erlang, crashes and decides to LFE" do
    assert ProblemC.learn(:bob, :erlang) == :ok
    Agent.stop(:bob, :crash)

    # Wait for Bob to restart
    :timer.sleep(500)

    assert ProblemC.learn(:bob, :lfe) == :ok
    assert ProblemC.languages(:bob) == [:lfe]
  end

  @tag :capture_log
  test "Bob learns Erlang, Alice crashes and Bob still knows Erlang" do
    assert ProblemC.learn(:bob, :erlang) == :ok
    Agent.stop(:alice, :crash)

    # Wait for Alice to restart
    :timer.sleep(500)

    assert ProblemC.learn(:alice, :elixir) == :ok
    assert ProblemC.languages(:bob) == [:erlang]
  end
end
