defmodule InfoSys.CacheTest do
  use ExUnit.Case, async: true
  alias InfoSys.Cache

  # Shortend time as default interval.
  @moduletag clear_interval: 100

  setup(context) do
    # Use the test name as a cache name.
    %{test: name, clear_interval: clear_interval} = context

    {:ok, pid} = Cache.start_link(name: name, clear_interval: clear_interval)

    # Provide cache name and cache pid to each test.
    {:ok, %{name: name, pid: pid}}
  end

  test "key value pairs can be put and fetched from cache", %{name: name} do
    assert :ok == Cache.put(name, :key1, :value1)
    assert :ok == Cache.put(name, :key2, :value2)

    assert Cache.fetch(name, :key1) == {:ok, :value1}
    assert Cache.fetch(name, :key2) == {:ok, :value2}
  end

  test "unfound entry returns error", %{name: name} do
    assert Cache.fetch(name, :nonexistent) == :error
  end

  test "clears all entries after clear interval", %{name: name} do
    assert :ok = Cache.put(name, :key1, :value1)
    assert Cache.fetch(name, :key1) == {:ok, :value1}

    assert eventually(fn -> Cache.fetch(name, :key1) == :error end)
  end

  # Override the default value with longer time.
  @tag clear_interval: 60_000
  test "values are cleaned up on exit", %{name: name, pid: pid} do
    assert :ok = Cache.put(name, :key1, :value1)

    # Kill the process and restart it.
    assert_shutdown(pid)
    {:ok, _cache} = Cache.start_link(name: name)

    assert Cache.fetch(name, :key1) == :error
  end

  # Verifies a server shuts down cleanly.
  defp assert_shutdown(pid) do
    # Start a monitor for the cache.
    ref = Process.monitor(pid)
    # Remove the link so that killing the server won't let our test process also crash.
    Process.unlink(pid)
    Process.exit(pid, :kill)
    # Make sure we get a :DOWN message on the monitor.
    assert_receive {:DOWN, ^ref, :process, ^pid, :killed}
  end

  # Executes a function until it eventually returns `true`.
  defp eventually(func) do
    if func.() do
      true
    else
      Process.sleep(10)
      eventually(func)
    end
  end
end
