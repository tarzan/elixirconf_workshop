defmodule ProblemKTest do
  use ExUnit.Case
  doctest ProblemK

  test "supervisor starts task" do
    starter = self()
    fun = fn() ->
      send(starter, {:im_alive, self()})

      # wait forever!
      :timer.sleep(:infinity)
    end

    assert {:ok, sup} = ProblemK.start_link(fun)
    assert is_pid(sup)

    assert_receive {:im_alive, task}

    assert sup != task

    refute_receive {:im_alive, _}
  end

  test "supervisor stops task before it exits" do
    Process.flag(:trap_exit, true)

    starter = self()
    ref = make_ref()
    fun = fn() ->
      Process.flag(:trap_exit, true)
      send(starter, {:im_alive, self()})

      receive do
        {:die, ^ref} ->
          exit(:shutdown)
      end
    end

    {:ok, sup} = ProblemK.start_link(fun)

    assert_receive {:im_alive, task}

    Process.exit(sup, :shutdown)

    refute_receive {:EXIT, ^sup, _}

    send(task, {:die, ref})

    assert_receive {:EXIT, ^sup, :shutdown}
    refute Process.alive?(task)

    refute_receive {:im_alive, _}
  end

  test "supervisor restarts task" do
    starter = self()
    fun = fn() ->
      send(starter, {:im_alive, self()})

      # wait forever!
      :timer.sleep(:infinity)
    end

    {:ok, _} = ProblemK.start_link(fun)

    assert_receive {:im_alive, task1}

    ref = Process.monitor(task1)
    Process.exit(task1, :crash)
    assert_receive {:DOWN, ^ref, _, _, :crash}

    assert_receive {:im_alive, task2}

    ref2 = Process.monitor(task2)
    Process.exit(task2, :crash)
    assert_receive {:DOWN, ^ref2, _, _, :crash}

    assert_receive {:im_alive, _}

    refute_receive {:im_alive, _}
  end

  test "supervisor ignores random EXIT signal" do
    starter = self()
    fun = fn() ->
      send(starter, {:im_alive, self()})

      # wait forever!
      :timer.sleep(:infinity)
    end

    {:ok, sup} = ProblemK.start_link(fun)

    assert_receive {:im_alive, _}

    Task.start_link(Process, :exit, [sup, :crash])

    refute_receive {:im_alive, _}
  end
end
