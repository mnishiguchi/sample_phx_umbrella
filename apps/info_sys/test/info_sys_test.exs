defmodule InfoSysTest do
  use ExUnit.Case
  alias InfoSys.Result

  # A stub that acts like our Wolfram backend.
  defmodule TestBackend do
    def name() do
      "Wolfram"
    end

    def compute("result", _opts) do
      [%Result{backend: __MODULE__, text: "result"}]
    end

    def compute("none", _opts) do
      []
    end

    # Sleeps forever.
    def compute("timeout", _opts) do
      Process.sleep(:infinity)
    end

    # Raises error.
    def compute("boom", _opts) do
      raise "boom!"
    end
  end

  test "compute/2 with sbackend results" do
    assert [%Result{backend: TestBackend, text: "result"}] =
             InfoSys.compute("result", backends: [TestBackend])
  end

  test "compute/2 with no backend results" do
    assert [] = InfoSys.compute("none", backends: [TestBackend])
  end

  test "compute/2 with timeout returns no results" do
    # Shorten the timeout inverval so that our test is fast.
    results = InfoSys.compute("timeout", backends: [TestBackend], timeout: 10)
    assert results == []
  end

  # Capture the log in order to keep our test from printing out error messages
  # when the exeption fires.
  @tag :capture_log
  test "compute/2 discards backend errors" do
    assert InfoSys.compute("boom", backends: [TestBackend]) == []
  end
end
