defmodule ProblemC do
  @moduledoc """
  Instead of using `Task.await/2` which crashes the process after the timeout has expired, `Task.yield/2`
  allows you to handle however you'd like after the timeout expires. The default is to return `nil`.
  """

  def get(timeout) do
    task = Task.async(fn -> slow_request() end)
    # only change below
    case Task.yield(task, timeout) do
      {:ok, result} -> result
      nil           -> :request_timeout
    end
  end

  defp slow_request() do
    HTTPoison.get("https://bbc.com")
  end
end
