defmodule ProblemC do
  @moduledoc """
  Handle timeout for an external request.
  """

  def get(timeout) do
    task = Task.async(fn -> slow_request() end)
    # only change below
    Task.await(timeout, timeout)
  end

  defp slow_request() do
    HTTPoison.get("https://bbc.com")
  end
end
