# ProblemC

A `GenServer` module with `init/1` returning `:ignore` can run code that blocks
the supervision tree. This can be used as part of recovering the workers under a
`:simple_one_for_one`. However the process storing the recovery data might enter
bad state, handle this!
