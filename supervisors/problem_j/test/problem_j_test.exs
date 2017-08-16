defmodule ProblemJTest do
  use ExUnit.Case
  doctest ProblemJ

  setup do
    {:ok, pid} = ProblemJ.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "calls run without deadlock" do
    counter = :sys.get_state(ProblemJ.Carol)

    # wait for system to run
    :timer.sleep(100)

    assert :sys.get_state(ProblemJ.Carol) > counter
  end

  @tag :capture_log
  test "system can handle Alice crashing" do
    GenServer.stop(ProblemJ.Alice, :crash)

    # wait for restarts
    :timer.sleep(100)

    counter = :sys.get_state(ProblemJ.Carol)

    # wait for system to run
    :timer.sleep(100)

    assert :sys.get_state(ProblemJ.Carol) > counter
  end

  @tag :capture_log
  test "system can handle Bob crashing" do
    GenServer.stop(ProblemJ.Bob, :crash)

    # wait for restarts
    :timer.sleep(100)

    counter = :sys.get_state(ProblemJ.Carol)

    # wait for system to run
    :timer.sleep(100)

    assert :sys.get_state(ProblemJ.Carol) > counter
  end

  @tag :capture_log
  test "system can handle Carol crashing" do
    GenServer.stop(ProblemJ.Carol, :crash)

    # wait for restarts
    :timer.sleep(100)

    counter = :sys.get_state(ProblemJ.Carol)

    # wait for system to run
    :timer.sleep(100)

    assert :sys.get_state(ProblemJ.Carol) > counter
  end
end
