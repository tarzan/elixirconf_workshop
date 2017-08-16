defmodule ProblemHTest do
  use ExUnit.Case
  doctest ProblemH

  setup do
    {:ok, pid} = ProblemH.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "server has clients counter" do
    :sys.suspend(ProblemH.Server)
    counter = :sys.get_state(ProblemH.Server)
    assert :sys.get_state(ProblemH.Client) == counter
  end

  @tag :capture_log
  test "system can handle server crash" do
    GenServer.stop(ProblemH.Client, :crash)

    # wait for restarts
    :timer.sleep(100)

    :sys.suspend(ProblemH.Server)
    counter = :sys.get_state(ProblemH.Server)
    assert :sys.get_state(ProblemH.Client) == counter
  end

  @tag :capture_log
  test "system can handle client crash" do
    GenServer.stop(ProblemH.Client, :crash)

    # wait for restarts
    :timer.sleep(100)

    :sys.suspend(ProblemH.Server)
    counter = :sys.get_state(ProblemH.Server)
    assert :sys.get_state(ProblemH.Client) == counter
  end
end
