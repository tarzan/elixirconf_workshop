defmodule ProblemITest do
  use ExUnit.Case
  doctest ProblemI

  setup do
    {:ok, pid} = ProblemI.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "server has clients counter" do
    :sys.suspend(ProblemI.Server)
    counter = :sys.get_state(ProblemI.Server)
    assert :sys.get_state(ProblemI.Client) == counter
  end

  @tag :capture_log
  test "system can handle server crash" do
    GenServer.stop(ProblemI.Client, :crash)

    # wait for restarts
    :timer.sleep(100)

    :sys.suspend(ProblemI.Server)
    counter = :sys.get_state(ProblemI.Server)
    assert :sys.get_state(ProblemI.Client) == counter
  end

  @tag :capture_log
  test "system can handle client crash" do
    GenServer.stop(ProblemI.Client, :crash)

    # wait for restarts
    :timer.sleep(100)

    :sys.suspend(ProblemI.Server)
    counter = :sys.get_state(ProblemI.Server)
    assert :sys.get_state(ProblemI.Client) == counter
  end
end
