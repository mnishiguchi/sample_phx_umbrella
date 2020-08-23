defmodule InfoSys do
  @moduledoc """
  A generic information system that supports certain background services.
  It spawns tasks to concurrently query each available backend service, fetches
  responsed from each and caches the result. Then it picks the best result.
  """

  # A list of supported backend services.
  @default_backends [InfoSys.Wolfram]

  # A data container for a search result.
  defmodule Result do
    defstruct score: 0,
              text: nil,
              backend: nil
  end

  alias InfoSys.Cache

  @doc """
  A main entry point for InfoSys.
  Performs the query for each available backend service.

  ## Examples

      iex> InfoSys.compute("What is elixir?")

      [%InfoSys.Result{
          backend: InfoSys.Wolfram,
          score: 95,
          text: "1 | noun | a sweet flavored liquid" }]

  """
  def compute(query, opts \\ []) do
    timeout = opts[:timeout] || 10_000
    opts = Keyword.put_new(opts, :limit, 10)
    backends = opts[:backends] || @default_backends

    # Fetch cached results for a given query term and narrow the list of backend
    # services that need to make the API requests.
    {uncached_backends, cached_results} = fetch_cached_results(backends, query, opts)

    uncached_backends
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
    |> write_results_to_cache(query, opts)
    |> Kernel.++(cached_results)
    |> Enum.sort(&(&1.score >= &2.score))
    |> Enum.take(opts[:limit])
  end

  defp fetch_cached_results(backends, query, opts) do
    # Initially both `uncached_backends` and `results` are an empty list.
    # For each backend service, if cached results are found, prepend them to
    # `results` else prepend that backend atom to `uncached_backends`.
    {uncached_backends, results} =
      Enum.reduce(
        backends,
        {[], []},
        fn backend, {uncached_backends, acc_results} ->
          case Cache.fetch(cache_key(backend, query, opts[:limit])) do
            {:ok, results} -> {uncached_backends, [results | acc_results]}
            :error -> {[backend | uncached_backends], acc_results}
          end
        end
      )

    {uncached_backends, List.flatten(results)}
  end

  defp write_results_to_cache(results, query, opts) do
    Enum.map(results, fn %Result{backend: backend} = result ->
      :ok = Cache.put(cache_key(backend, query, opts[:limit]), result)
      result
    end)
  end

  # Standardizes on a composite cache key.
  defp cache_key(backend, query, limit) do
    {backend.name(), query, limit}
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
