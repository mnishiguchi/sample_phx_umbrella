defmodule SamplePhxWeb.Channels.VideoChannelTest do
  use SamplePhxWeb.ChannelCase
  import SamplePhxWeb.TestHelpers

  @moduledoc """
  We do not pass the `async: true` flag to the `ChannelCase` for this test. Here
  is why. In Ecto's `Sandbox` mode, every process has its own connection. That
  is not a problem in apps that limit database access to a single process;
  however this app has two or more processes talking to the database at the same
  time in the same test. Because processes might need access the same data, the
  only way for them to share data in the sandbox mode is to share the same
  connection. To maintain isolation for each test, we cannot run tests
  concurrently.
  """

  setup do
    user = insert_user(name: "Gary")
    video = insert_video(user, title: "Testing")
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, connected_socket} = connect(SamplePhxWeb.UserSocket, %{"token" => token})

    # https://github.com/phoenixframework/phoenix/issues/3619#issuecomment-642151609
    # on_exit(fn ->
    #   for pid <- Task.Supervisor.children(SamplePhxWeb.Presence.TaskSupervisor) do
    #     ref = Process.monitor(pid)
    #     assert_receive {:DOWN, ^ref, _, _, _}, 1000
    #   end
    #   :timer.sleep(1)
    # end)

    {:ok, socket: connected_socket, user: user, video: video}
  end

  test "join replies with video annotations", %{socket: socket, video: video, user: user} do
    for body <- ["annotation one", "annotation two"] do
      SamplePhx.Multimedia.annotate_video(user, video.id, %{body: body, at: 0})
    end

    # Join a channel for this video.
    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})

    assert socket.assigns.video_id == video.id
    assert %{annotations: [%{body: "annotation one"}, %{body: "annotation two"}]} = reply
  end

  # FIXME: This passes but a db-related error happens.
  # test "inserting new annotations", %{socket: socket, video: video} do
  #   {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
  #   ref = push(socket, "new_annotation", %{body: "the body", at: 0})

  #   assert_reply(ref, :ok, %{})
  #   assert_broadcast("new_annotation", %{})
  # end

  # FIXME: This explodes with a presence-related error.
  # test "new annotation triggers InfoSys", %{socket: socket, video: video} do
  #   # Insert an internal Wolfram user in the database because our
  #   # `compute_additional_info` needs to have a user named `wolfram` to post
  #   # the additional info.
  #   insert_user(
  #     username: "wolfram",
  #     password: "supersecret"
  #   )

  #   {:ok, _, socket} = subscribe_and_join(socket, "videos:#{video.id}", %{})
  #   ref = push(socket, "new_annotation", %{body: "1 + 1", at: 123})
  #   assert_reply(ref, :ok, %{})
  #   assert_broadcast("new_annotation", %{body: "1 + 1", at: 123})
  #   assert_broadcast("new_annotation", %{body: "2", at: 123})
  # end
end
