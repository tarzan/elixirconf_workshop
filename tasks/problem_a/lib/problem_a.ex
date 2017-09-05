defmodule ProblemA do
  @moduledoc """
  By default, when a process reaches its end, it exits with :normal. To handle non-normal exits, pass any term
  to exit/1 like exit(:stop) in the question.

  Note that if the reason is anything other than :normal, all the processes linked to the process that exited will
  also crash, unless they're trapping exits.
  """

  @doc """
  Start and links to process that stops when it receives the message `:stop`.
  """
  def start_link() do
    Task.start_link(fn() ->
      receive do
        :stop ->
          exit(:normal)
      end
    end)
  end
end
