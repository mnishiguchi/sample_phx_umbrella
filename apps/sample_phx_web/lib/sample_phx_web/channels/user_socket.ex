defmodule SamplePhxWeb.UserSocket do
  use Phoenix.Socket

  ## Channels
  channel "videos:*", SamplePhxWeb.VideoChannel

  # max_age: 1209600 is equivalent to two weeks in seconds
  @max_age 2 * 7 * 24 * 60 * 60

  # Socket params are passed from the client and can
  # be used to verify and authenticate a user. After
  # verification, you can put default assigns into
  # the socket that will be set for all channels, ie
  #
  #     {:ok, assign(socket, :user_id, verified_user_id)}
  #
  # To deny connection, return `:error`.
  #
  # See `Phoenix.Token` documentation for examples in
  # performing token verification on connect.
  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    # Verify the user token provided by the client. Tokens are only valid for a certain period of
    # time.
    case Phoenix.Token.verify(socket, "user socket", token, max_age: @max_age) do
      # If the token is valid, we receive the `user_id` and establish the connection.
      {:ok, user_id} ->
        {:ok, assign(socket, :user_id, user_id)}

      # If the token is invalid, we deny the connection attempt by the client.
      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info) do
    :error
  end

  # Socket id's are topics that allow you to identify all sockets for a given user:
  #
  #     def id(socket), do: "user_socket:#{socket.assigns.user_id}"
  #
  # Would allow you to broadcast a "disconnect" event and terminate
  # all active sockets and channels for a given user:
  #
  #     SamplePhxWeb.Endpoint.broadcast("user_socket:#{user.id}", "disconnect", %{})
  #
  # Returning `nil` makes this socket anonymous.
  @impl true
  def id(socket) do
    "user_socket:#{socket.assigns.user_id}"
  end
end
