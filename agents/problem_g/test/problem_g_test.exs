defmodule ProblemGTest do
  use ExUnit.Case
  doctest ProblemG

  test "ping replies with pong" do
    {:ok, pid} = ProblemG.start_link()
    assert ProblemG.call(pid, :ping, 5000) == :pong
    assert ProblemG.call(pid, :ping, 5000) == :pong
  end

  test "successfull call flushes monitor" do
    {:ok, pid} = ProblemG.start_link()
    assert ProblemG.call(pid, :ping, 5000) == :pong
    # check monitor to pid does not exist)
    assert {_, monitored} = Process.info(pid, :monitored_by)
    refute self() in monitored
  end

  test "ignored call times out and flushes monitor" do
    {:ok, pid} = ProblemG.start_link()
    assert catch_exit(ProblemG.call(pid, :ignore, 123)) ==
      {:timeout, {ProblemG, :call, [pid, :ignore, 123]}}

    # check monitor to pid does not exist)
    assert {_, monitored} = Process.info(pid, :monitored_by)
    refute self() in monitored
  end

  @tag :capture_log
  test "process stops while call in progress" do
    Process.flag(:trap_exit, true)
    {:ok, pid} = ProblemG.start_link()

    assert catch_exit(ProblemG.call(pid, :stop, 123)) ==
      {:stop, {ProblemG, :call, [pid, :stop, 123]}}

    refute Process.alive?(pid)
  end
end
