defmodule InfoSys.Test.HTTPClient do
  @moduledoc """
  A test stub for an HTTP client. Used for testing our code that parses the data
  Wolfram provides.
  """

  @wolfram_xml File.read!("test/fixtures/wolfram.xml")

  @doc """
  Stubs `request/1` and returns fake Wolfram results. Returns results when the
  url contains "1 + 1".
  """
  def request(url) do
    url = to_string(url)

    cond do
      String.contains?(url, "1+%2B+1") ->
        {:ok, {[], [], @wolfram_xml}}

      true ->
        {:ok, {[], [], "<queryresult></queryresult>"}}
    end
  end
end
