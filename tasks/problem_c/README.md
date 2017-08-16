# ProblemC

Handle timeout from Task.async/1 for external request gracefully. This means that if the request times out, it should return an atom :request_timeout instead of crashing.

```
iex> h Task.async/1

```

## Installation

* Run `mix deps.get` to get the dependencies.
* Start with `iex -S mix` from the current directory
