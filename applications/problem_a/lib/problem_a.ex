## See problem_a/application.ex
defmodule ProblemA do
  @moduledoc false

  defmodule Data do
    @moduledoc false

    use Agent, start: {__MODULE__, :start_link, []}

    def start_link() do
      Agent.start_link(fn() -> %{alice: MapSet.new(), bob: MapSet.new()} end,
      [name: __MODULE__])
    end

    def put(name, value) do
      Agent.update(__MODULE__, &Map.put(&1, name, value))
    end

    def fetch!(name) do
      Agent.get(__MODULE__, &Map.fetch!(&1, name))
    end
  end

  defmodule Alice do
    @moduledoc false

    alias ProblemA.Data
    use Agent, start: {__MODULE__, :start_link, []}

    def start_link() do
      Agent.start_link(fn() -> Data.fetch!(:alice) end, [name: __MODULE__])
    end

    def learn(:elixir) do
      Agent.update(__MODULE__, fn(state) ->
        state = MapSet.put(state, :elixir)
        Data.put(:alice, state)
        state
      end)
    end
    def learn(language) do
      Agent.update(__MODULE__, &MapSet.put(&1, language))
    end

    def languages() do
      Agent.get(__MODULE__, &Enum.to_list/1)
    end
  end

  defmodule Bob do
    @moduledoc false

    alias ProblemA.Data
    use Agent, start: {__MODULE__, :start_link, []}

    def start_link() do
      Agent.start_link(fn() -> Data.fetch!(:bob) end, [name: __MODULE__])
    end

    def learn(language) do
      Agent.update(__MODULE__, fn(state) ->
        state = MapSet.put(state, language)
        Data.put(:bob, state)
        state
      end)
    end

    def languages() do
      Agent.get(__MODULE__, &Enum.to_list/1)
    end
  end
end
