defmodule ProblemGTest do
  use ExUnit.Case
  doctest ProblemG

  setup do
    {:ok, pid} = ProblemG.start_link()
    on_exit(fn() ->
      # wait for process to terminate
      ref = Process.monitor(pid)
      assert_receive {:DOWN, ^ref, _, _, _}
    end)
  end

  test "process can subscribe and unsubscribe to server" do
    ref1 = ProblemG.subscribe()
    ref2 = ProblemG.subscribe()

    assert_receive {:tick, ^ref2, counter1}
    assert_receive {:tick, ^ref1, ^counter1}

    assert ProblemG.unsubscribe(ref1) == :ok

    assert ProblemG.unsubscribe(ref1) == :error

    flush_ticks(ref1)
    flush_ticks(ref2)

    assert_receive {:tick, ^ref2, counter2}
    counter3 = counter2 + 1
    assert_receive {:tick, ^ref2, ^counter3}

    # if ref1 subscription still active would have received counter2 tick before
    # any counter3 ticks sent to the same process.
    refute_received {:tick, ^ref1, ^counter2}
  end

  @tag :capture_log
  test "server can handle client crash" do
    ref = ProblemG.subscribe()
    GenServer.stop(ProblemG.Client, :crash)

    # wait for restarts
    :timer.sleep(100)
    flush_ticks(ref)
    assert_receive {:tick, ^ref, _}

    client_ref = :sys.get_state(ProblemG.Client)
    assert %{^client_ref => _} = :sys.get_state(ProblemG.Server)
  end

  @tag :capture_log
  test "client subscribed after server crash" do
    GenServer.stop(ProblemG.Server, :crash)

    # wait for restarts
    :timer.sleep(100)

    client_ref = :sys.get_state(ProblemG.Client)
    assert %{^client_ref => _} = :sys.get_state(ProblemG.Server)
  end

  defp flush_ticks(ref) do
    receive do
      {:tick, ^ref, _} ->
        flush_ticks(ref)
    after
      0 ->
        :ok
    end
  end
end
