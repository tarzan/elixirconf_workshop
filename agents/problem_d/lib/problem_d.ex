defmodule ProblemD do
  @moduledoc """
  use Genserver to fetch random number at a specific from random.org and print the number.
  For failure, handle two cases:
    if the request times out, print "request timeout"
    if there's a legitimate error, print "request error"
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
    resp = HTTPoison.get(@random, [], [recv_timeout: timeout])
    # handle success and failure
    IO.inspect resp
    {:noreply, timeout}
  end
end
