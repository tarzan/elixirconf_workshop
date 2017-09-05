defmodule ProblemC do
  @moduledoc """
  ProblemC.
  """

  alias __MODULE__.Person

  @doc """
  Start two people: Alice and Bob, always and forever.
  """

  def start_link() do
    Supervisor.start_link([
      {Person, :alice},
      {Person, :bob}
    ], [strategy: :one_for_one, restarts: :infinity])
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
