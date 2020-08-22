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
    timeout = opts[:timeout] || 10_000
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @default_backends

    backends
    |> Enum.map(&async_query(&1, query, opts))
    # Wait on all tasks.
    |> Task.yield_many(timeout)
    |> Enum.map(fn
      # Shutdown immediately if response is nil.
      {task, response} -> response || Task.shutdown(task, :brutal_kill)
    end)
    |> Enum.flat_map(fn
      {:ok, results} -> results
      _ -> []
    end)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(opts[:limit])
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
