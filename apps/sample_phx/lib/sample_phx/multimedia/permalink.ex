defmodule SamplePhx.Multimedia.Permalink do
  @behaviour Ecto.Type

  @moduledoc """
  A custom type defined according to the `Ecto.Type` behaviour. It expects us to define four functions: type, cast, dump and load.

  ## Examples

      iex> SamplePhx.Multimedia.Permalink.cast("1")
      {:ok, 1}

      iex> SamplePhx.Multimedia.Permalink.cast("13-hello-world")
      {:ok, 13}

      iex> SamplePhx.Multimedia.Permalink.cast("hello-world-13")
      :error

  """

  @doc """
  Returns the underlying `Ecto.Type`.
  """
  def type, do: :id

  @doc """
  By design, the `cast` function often processes end-user input.
  """
  def cast(binary) when is_binary(binary) do
    case Integer.parse(binary) do
      {parsed_int, _} when parsed_int > 0 -> {:ok, parsed_int}
      _ -> :error
    end
  end

  def cast(integer) when is_integer(integer) do
    {:ok, integer}
  end

  @doc """
  Called when external data is passed into Ecto. It is invoked when values in queries are in terpolated or also by the `cast` function in changesets.
  """
  def cast(_) do
    :error
  end

  @doc """
  Invoked when data is sent to the database.
  """
  def dump(integer) when is_integer(integer) do
    {:ok, integer}
  end

  @doc """
  Invoked when data is loaded from the database.
  """
  def load(integer) when is_integer(integer) do
    {:ok, integer}
  end
end
