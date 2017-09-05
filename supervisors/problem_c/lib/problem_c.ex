defmodule ProblemC do
  @moduledoc """
  The solution is the same as the last problem. We change GenServer to Supervisor and then set up Alice and Bob as children
  of that Supervisor. Always and forever in this case means :one_for_one since if one crashes we only want to restart that one.
  """

  alias __MODULE__.Person

  @doc """
  Start two people: Alice and Bob, always and forever.
  """

  def start_link() do
    Supervisor.start_link(__MODULE__, nil)
  end

  def init(_) do
    Supervisor.init([{Person, :bob}, {Person, :alice}], [strategy: :one_for_one])
  end

  ## Do not change code below

  defdelegate learn(person, language), to: Person
  defdelegate languages(person), to: Person
  defdelegate forget(person), to: Person

  defmodule Person do
    @moduledoc false

    use Agent

    def child_spec(name) do
      name
      |> super()
      |> Supervisor.child_spec([id: name])
    end

    def start_link(name) do
      Agent.start_link(&MapSet.new/0, name: name)
    end

    def learn(person, language) do
      Agent.update(person, &MapSet.put(&1, language))
    end

    def languages(person) do
      Agent.get(person, &MapSet.to_list/1)
    end

    def forget(person) do
      Agent.update(person, fn(_) -> MapSet.new() end)
    end
  end
end
