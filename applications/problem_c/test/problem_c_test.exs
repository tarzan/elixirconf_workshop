defmodule ProblemCTest do
  use ExUnit.Case
  doctest ProblemC

  setup_all do
    Application.stop(:problem_c)
    on_exit(fn() -> Application.start(:problem_c) end)
  end

  setup do
    :ok = Application.start(:problem_c)
    on_exit(fn() -> Application.stop(:problem_c) end)
  end

  test "Alice and Bob are automatically recovered" do
    assert GenServer.whereis(:alice)
    assert GenServer.whereis(:bob)
  end

  test "dynamically starting Carol" do
    assert ProblemC.ping(:carol) == :pong
    assert ProblemC.ping(:carol) == :pong
  end

  test "dynamically starting Carol and crashing Carol trigggers full recover" do
    alice = GenServer.whereis(:alice)
    bob = GenServer.whereis(:bob)

    assert ProblemC.ping(:carol) == :pong

    GenServer.stop(:carol, :crash)
    # Wait for restarts
    :timer.sleep(100)

    GenServer.stop(:carol, :crash)
    # Wait for restarts
    :timer.sleep(100)

    assert GenServer.whereis(:carol) == nil

    assert %{active: 2} = Supervisor.count_children(ProblemC.ServerSupervisor)

    assert GenServer.whereis(:alice) != alice
    assert GenServer.whereis(:bob) != bob
  end

  test "Alice stops after normal exit but recovers after Bob crashing" do
    alice = GenServer.whereis(:alice)
    bob = GenServer.whereis(:bob)

    GenServer.stop(:alice, :normal)
    GenServer.stop(:bob, :crash)
    # Wait for restarts
    :timer.sleep(100)

    refute GenServer.whereis(:alice)

    GenServer.stop(:bob, :crash)
    # Wait for restarts
    :timer.sleep(100)

    assert %{active: 2} = Supervisor.count_children(ProblemC.ServerSupervisor)

    assert GenServer.whereis(:alice) != alice
    assert GenServer.whereis(:bob) != bob
  end

  test "system eventually recovers after adding bad server" do
    ProblemC.Tracker.put(:crash)
    Supervisor.stop(ProblemC.ServerSupervisor)

    # Wait for restarts
    :timer.sleep(100)

    assert %{active: 2} = Supervisor.count_children(ProblemC.ServerSupervisor)

    assert GenServer.whereis(:alice)
    assert GenServer.whereis(:bob)
  end
end
