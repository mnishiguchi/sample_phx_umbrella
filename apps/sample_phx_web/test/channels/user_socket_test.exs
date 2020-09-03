defmodule SamplePhxWeb.Channels.UserSocketTest do
  use SamplePhxWeb.ChannelCase, async: true
  alias SamplePhxWeb.UserSocket

  @moduledoc """
  Most of our channels code relies on an authenticated user. Since these tests
  do not require side effects such as database calls, they run independently and
  concurrently.
  """

  test "socket authentication with valid token" do
    valid_token = Phoenix.Token.sign(@endpoint, "user socket", "123")

    assert {:ok, socket} = connect(UserSocket, %{"token" => valid_token})
    assert socket.assigns.user_id == "123"
  end

  test "socket authentication with invalid token" do
    assert :error = connect(UserSocket, %{"token" => "1313"})
    assert :error = connect(UserSocket, %{})
  end
end
