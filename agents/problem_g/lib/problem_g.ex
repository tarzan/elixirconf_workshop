defmodule ProblemG do
  @moduledoc """
  ProblemG.
  """

  @doc """
  Start task.
  """
  def start_link() do
    Task.start_link(__MODULE__, :loop, [])
  end

  # Only change call/3 and reply/2; use the message structure defined in loop/0.

  @doc """
  Call task.
  """
  def call(task, request, timeout)

  @doc """
  Reply to call
  """
  def reply(from, response)

  @doc false
  def loop() do
    receive do
      {__MODULE__, from, :ping} ->
        __MODULE__.reply(from, :pong)
        loop()
      {__MODULE__, _, :ignore} ->
        loop()
      {__MODULE__, _, :stop} ->
        exit(:stop)
    end
  end
end
