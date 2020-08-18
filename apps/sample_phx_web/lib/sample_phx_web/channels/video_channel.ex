defmodule SamplePhxWeb.VideoChannel do
  use SamplePhxWeb, :channel

  alias SamplePhx.{Accounts, Multimedia}
  alias SamplePhxWeb.{Presence, AnnotationView}

  @doc """
  Socket will hold all of the state for a given conversation. Each socket can
  hold all of the state in the `socket.assigns` field.
  "videos:" <> video_id will match all topics starting with "videos:" and assign
  the rest of the topic to the video_id variable.
  """
  def join("videos:" <> video_id, params, socket) do
    send(self(), :after_join)

    last_seen_id = params["last_seen_id"] || 0
    video_id = String.to_integer(video_id)
    video = Multimedia.get_video!(video_id)

    annotations =
      video
      |> Multimedia.list_annotations(last_seen_id)
      |> Phoenix.View.render_many(AnnotationView, "annotation.json")

    {:ok, %{annotations: annotations}, assign(socket, :video_id, video_id)}
  end

  @doc """
  Catches all incoming events and ensures that they have the current user. Then
  calls handle_in/4 with the socket user.
  """
  def handle_in(event, params, socket) do
    user = Accounts.get_user!(socket.assigns.user_id)
    handle_in(event, params, user, socket)
  end

  @doc """
  The `broadcast!` function sends an event to all users on the current topic.
  Behind the scenes, `broadcast!` uses Phoenix's Publish and Subscribe (PubSub)
  system to send the message to all processes listening on the given topic.
  """
  def handle_in("new_annotation", params, user, socket) do
    case Multimedia.annotate_video(user, socket.assigns.video_id, params) do
      {:ok, annotation} ->
        # The payload is delivered to all clients on this topic. Be sure to
        # control the payload as closely as possible.
        broadcast!(socket, "new_annotation", %{
          id: annotation.id,
          user: SamplePhxWeb.UserView.render("user.json", %{user: user}),
          body: annotation.body,
          at: annotation.at
        })

        # We could have decided not to send a reply with `{:noreply, socket}`,
        # but it is common practice to acknowledge the result of the pushed
        # message from the client. Also, this approach allows the client easily
        # implement UI features even if we only reply with an `:ok` or `:error`.
        {:reply, :ok, socket}

      {:error, changeset} ->
        {:reply, {:error, %{errors: changeset}}, socket}
    end
  end

  @doc """
  Handles a user-defined message called `:after_join`.
  """
  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    # A user is a unique entity within the presence. A user can have multiple
    # sessions, such as a single user with open browser tabs or multiple
    # devices.
    {:ok, _} =
      Presence.track(
        socket,
        # A key to track.
        socket.assigns.user_id,
        # A map of metadata, any arbitrary data we want to associate with a
        # session.
        %{device: "browser"}
      )

    # Simply return our unchanged socket.
    {:noreply, socket}
  end
end
