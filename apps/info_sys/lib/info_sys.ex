defmodule InfoSys do
  @moduledoc """
  A generic information system that supports certain background services.
  It spawns tasks to concurrently query each available backend service, fetches
  responsed from each and caches the result. Then it picks the best result.
  """

  # A list of supported backend services.
  @default_backends [InfoSys.Wolfram]

  # A data container for a serch result.
  defmodule Result do
    defstruct score: 0,
              text: nil,
              backend: nil
  end

  @doc """
  A main entry point for InfoSys.
  Performs the query for each available backend service.
  """
  def compute(query, opts \\ []) do
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @default_backends

    backends
    |> Enum.map(&async_query(&1, query, opts))
  end

  # Spawns off a task in a new process. Returns a Task struct.
  defp async_query(backend, query, opts) do
    # We use `async_nolink` to spawn the task isolated from our caller, allowing
    # our clients to query backends and not be worried about a crash or
    # unexpected error. If the result does not come back from one of our
    # services, the supervisor will kill it.
    Task.Supervisor.async_nolink(
      InfoSys.TaskSupervisor,
      backend,
      :compute,
      [query, opts],
      shutdown: :brutal_kill
    )
  end
end
