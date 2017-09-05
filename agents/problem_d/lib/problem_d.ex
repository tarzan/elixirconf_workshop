defmodule ProblemD do
  @moduledoc """
  This is a real world example of handling success and failure for external resource fetching. In this case all you
  need to do is pattern mactch on resp and print out the result if it's a success or return "request timeout" if it's an error.
  The return value of handle_info/2 can be a 2- or 3-tuple. In this case, it's a 2-tuple because we haven't implemented
  the callback.
  """
  use GenServer

  @random "https://www.random.org/integers/?num=1&min=1&max=100&col=1&base=10&format=plain&rnd=new"

  @doc """
  Starts a GenServer that prints a random number after some interval
  """
  def start_link(timeout) do
    GenServer.start_link(__MODULE__, timeout, [name: __MODULE__])
  end

  @doc false
  def init(timeout) do
    :timer.apply_interval(500, Kernel, :send, [self(), :get])
    {:ok, timeout}
  end

  # only change code below
  @doc false
  def handle_info(:get, timeout) do
    case HTTPoison.get(@random, [], [recv_timeout: timeout]) do
      {:error, _resp} -> "request timeout"
      {:ok, resp}     -> resp.body
    end
    |> IO.inspect
    {:noreply, timeout}
  end
end
