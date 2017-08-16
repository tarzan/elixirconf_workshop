defmodule ProblemFTest do
  use ExUnit.Case
  import ExUnit.CaptureIO
  doctest ProblemF

  setup do
    {:ok, pid} = ProblemF.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "increment is logged" do
    assert capture_io(:user, fn() ->
      assert ProblemF.increment(1) == 1
      assert ProblemF.last_log() == "increment 1 from 0 to 1"
    end) == "increment 1 from 0 to 1\n"
  end

  @tag :capture_log
  test "crash in logger does not effect incrementing" do
    assert capture_io(:user, fn() ->
      assert ProblemF.increment(1) == 1
      GenServer.stop(ProblemF.Logger, :crash)
      assert ProblemF.increment(2) == 3
      assert ProblemF.increment(3) == 6
      assert ProblemF.last_log() == "increment 3 from 3 to 6"
    end)
  end

  @tag :capture_log
  test "crash in server does not effect last message" do
    assert capture_io(:user, fn() ->
      assert ProblemF.increment(1) == 1
      GenServer.stop(ProblemF.Server, :crash)
      # wait for restart
      :timer.sleep(500)
      assert ProblemF.last_log() == "increment 1 from 0 to 1"
    end) == "increment 1 from 0 to 1\n"
  end
end
