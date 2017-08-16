defmodule ProblemBTest do
  use ExUnit.Case
  doctest ProblemB

  setup_all do
    Application.stop(:problem_b)
    on_exit(fn() -> Application.start(:problem_b) end)
  end

  setup do
    :ok = Application.start(:problem_b)
    on_exit(fn() -> Application.stop(:problem_b) end)
  end

  test "task that succeeds" do
    assert ProblemB.run(fn() -> 1 + 1 end) == {:ok, 2}
  end

  test "tasks can crash but the server survives" do
    server = GenServer.whereis(ProblemB.Server)

    n = 10
    assert List.duplicate({:error, :crash}, n)
      1..n
      |> Enum.map(fn(_) ->
        Task.async(fn() -> ProblemB.run(fn() -> exit(:crash) end) end)
      end)
      |> Enum.map(&Task.await(&1))

    assert GenServer.whereis(ProblemB.Server) == server
  end

  test "tasks are shut down when server crashes" do
    Process.flag(:trap_exit, true)

    %{ref: ref} = Task.async(ProblemB, :run, [fn() -> :timer.sleep(:infinity) end])

    GenServer.stop(ProblemB.Server, :crash)

    # Wait for restarts
    :timer.sleep(100)

    assert Supervisor.which_children(ProblemB.TaskSupervisor) == []

    assert_received {:DOWN, ^ref, _, _, {:crash, _}}
  end
end
