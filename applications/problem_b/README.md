# ProblemB

A `GenServer` starts async Tasks using a `Task.Supervisor`, rearrange the
supervision tree so that failed tasks do not crash the server, but a crash in
the server shuts down any tasks.
