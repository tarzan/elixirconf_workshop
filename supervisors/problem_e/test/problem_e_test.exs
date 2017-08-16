defmodule ProblemETest do
  use ExUnit.Case
  doctest ProblemE

  test "start an Agent under a supervisor" do
    {:ok, sup} = ProblemE.start_link()
    assert is_pid(sup)

    {:ok, agent} = ProblemE.start_child(sup, &Map.new/0)
    assert is_pid(agent)

    ref = Process.monitor(agent)
    Supervisor.stop(sup)
    assert_receive {:DOWN, ^ref, _, _, :shutdown}
  end

  test "start multiple Agents under a supervisor" do
    {:ok, sup} = ProblemE.start_link()
    assert is_pid(sup)

    {:ok, agent1} = ProblemE.start_child(sup, &Map.new/0)
    {:ok, agent2} = ProblemE.start_child(sup, &Map.new/0)
    refute agent1 == agent2

    assert Process.alive?(agent1)
    assert Process.alive?(agent2)
  end

  test "start Agent and use it" do
    {:ok, sup} = ProblemE.start_link()

    {:ok, agent} = ProblemE.start_child(sup, Enum, :into, [[foo: :bar], %{}])

    assert Agent.get(agent, &Map.get(&1, :foo)) == :bar
  end

  test "shutdown: :brutal_kill kills Agents" do
    {:ok, sup} = ProblemE.start_link([shutdown: :brutal_kill])


    {:ok, agent} = ProblemE.start_child(sup, &Map.new/0)
    ref = Process.monitor(agent)
    Supervisor.stop(sup)
    assert_receive {:DOWN, ^ref, _, _, :killed}
  end

  @tag :capture_log
  test "do not restart Agent on crash" do
    {:ok, sup} = ProblemE.start_link()

    starter = self()
    init =
      fn() ->
        send(starter, {:agent, self()})
        nil
      end
    {:ok, agent} = ProblemE.start_child(sup, init)

    assert_receive {:agent, ^agent}

    Agent.stop(agent, :crash)

    refute_receive {:agent, _}
  end

  @tag :capture_log
  test "restart Agent on crash if [restart: :transient]" do
    {:ok, sup} = ProblemE.start_link([restart: :transient])

    starter = self()
    init =
      fn() ->
        send(starter, {:agent, self()})
        nil
      end
    {:ok, agent1} = ProblemE.start_child(sup, init)

    assert_receive {:agent, ^agent1}

    Agent.stop(agent1, :crash)

    assert_receive {:agent, _}
  end

  test "shutdown on any exit if [max_restarts: 0, restart: :permanent]" do
    Process.flag(:trap_exit, true)
    {:ok, sup} = ProblemE.start_link([max_restarts: 0, restart: :permanent])

    {:ok, agent} = ProblemE.start_child(sup, &Map.new/0)
    Agent.stop(agent)
    assert_receive {:EXIT, ^sup, :shutdown}
  end
end
