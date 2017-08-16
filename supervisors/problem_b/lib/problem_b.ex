defmodule ProblemB do
  @moduledoc """
  ProblemB.
  """

  alias __MODULE__.{State, Server}

  @doc """
  Start an Agent to hold account balance and GenServer that updates it.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, nil)
  end

  @doc false
  def init(_) do
    {:ok, _} = State.start_link()
    {:ok, _} = Server.start_link()
    {:ok, nil}
  end

  ## Do not change code below

  @doc """
  Deposit money.
  """
  defdelegate deposit(amount), to: Server

  @doc """
  Withdaw money.
  """
  defdelegate withdraw(amount), to: Server

  @doc """
  Retrieve balance.
  """
  defdelegate balance(), to: Server

  defmodule State do
    @moduledoc false

    use Agent, start: {__MODULE__, :start_link, []}

    def start_link() do
      Agent.start_link(fn() -> 0 end, name: __MODULE__)
    end

    def balance() do
      Agent.get(__MODULE__, &(&1))
    end

    def deposit(amount) do
      Agent.update(__MODULE__, &(&1 + amount))
    end

    def withdraw(amount) do
      Agent.update(__MODULE__, &(&1 - amount))
    end
  end

  defmodule Server do
    @moduledoc false

    use GenServer, start: {__MODULE__, :start_link, []}
    alias ProblemB.State

    def start_link() do
      GenServer.start_link(__MODULE__, nil, [name: __MODULE__])
    end

    def deposit(amount), do: GenServer.call(__MODULE__, {:deposit, amount})

    def withdraw(amount), do: GenServer.call(__MODULE__, {:withdraw, amount})

    def balance(), do: GenServer.call(__MODULE__, :balance)

    def init(_) do
      {:ok, State.balance()}
    end

    def handle_call({:deposit, amount}, _, state) do
      :ok = State.deposit(amount)
      state = state+amount
      {:reply, state, state}
    end
    def handle_call({:withdraw, amount}, _, state) do
      :ok = State.withdraw(amount)
      state = state-amount
      {:reply, state, state}
    end
    def handle_call(:balance, _, state) do
      {:reply, state, state}
    end
  end
end
