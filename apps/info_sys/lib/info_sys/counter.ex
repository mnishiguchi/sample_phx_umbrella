defmodule InfoSys.Counter do
  use GenServer

  @moduledoc """
  ##Examples

      iex> {:ok, counter} = Counter.start_link(0)
      {:ok, #PID<0.196.0>}
      iex> Counter.inc(counter)
      :ok
      iex> Counter.val(counter)
      1
      iex> Counter.dec(counter)
      :ok
      iex> Counter.val(counter)
      0

  """

  # Client

  def inc(pid) do
    GenServer.cast(pid, :inc)
  end

  def dec(pid) do
    GenServer.cast(pid, :dec)
  end

  @spec val(atom | pid | {atom, any} | {:via, atom, any}) :: any
  def val(pid) do
    GenServer.call(pid, :val)
  end

  # Server

  def start_link(initial_val \\ 0) do
    GenServer.start_link(__MODULE__, initial_val)
  end

  def init(initial_state) do
    Process.send_after(self(), :tick, 1000)
    {:ok, initial_state}
  end

  def handle_info(:tick, state) when state <= 0, do: raise("Boom!")

  def handle_info(:tick, state) do
    IO.puts("tick #{state}")
    Process.send_after(self(), :tick, 1000)
    {:noreply, state - 1}
  end

  def handle_cast(:inc, state) do
    {:noreply, state + 1}
  end

  def handle_cast(:dec, state) do
    {:noreply, state - 1}
  end

  def handle_call(:val, _from, state) do
    {:reply, state, state}
  end
end
