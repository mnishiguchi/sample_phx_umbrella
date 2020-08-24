defmodule InfoSys.Backends.WolframTest do
  use ExUnit.Case, async: true

  @moduledoc """
  Makes sure that we can parse the data Wolfram provides.
  """

  test "makes request, reposts results, then terminates" do
    results = InfoSys.compute("1 + 1", [])
    assert hd(results).text == "2"
  end

  test "no query results reports an empty list" do
    assert InfoSys.compute("none", []) == []
  end
end
