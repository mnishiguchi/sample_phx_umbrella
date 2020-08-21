defmodule InfoSys.Cache do
  use GenServer

  @moduledoc """
  EXAMPLES

      iex> alias InfoSys.Cache
      InfoSys.Cache
      iex> Cache.put("one plus one?", "two")
      :ok
      iex> Cache.fetch("one plus one?")
      {:ok, "two"}
      iex> Cache.fetch("one plus three?")
      :error

  """

  def put(name \\ __MODULE__, key, value) do
    true = :ets.insert(table_name(name), {key, value})
    :ok
  end

  def fetch(name \\ __MODULE__, key) do
    {:ok, :ets.lookup_element(table_name(name), key, 2)}
  rescue
    # ETS throws an ArgumentError if we try to look up a nonexistent key.
    ArgumentError -> :error
  end

  def start_link(opts) do
    opts = Keyword.put_new(opts, :name, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: opts[:name])
  end

  # A millisecond value for clearing the cache.
  @default_clear_interval :timer.seconds(60)

  def init(opts) do
    initial_state = %{
      interval: opts[:clear_interval] || @default_clear_interval,
      timer: nil,
      table: new_table(opts[:name])
    }

    {:ok, schedule_clear(initial_state)}
  end

  # Clears cache and schedules for next.
  def handle_info(:clear, state) do
    :ets.delete_all_objects(state.table)
    {:noreply, schedule_clear(state)}
  end

  # Schedule to send :clear message in the future.
  defp schedule_clear(state) do
    %{state | timer: Process.send_after(self(), :clear, state.interval)}
  end

  def new_table(name) do
    name
    |> table_name()
    |> :ets.new([
      :set,
      :named_table,
      :public,
      read_concurrency: true,
      write_concurrency: true
    ])
  end

  # An atom of the table name to used for our ETS table.
  defp table_name(name) do
    :"#{name}_cache"
  end
end
