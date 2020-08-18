defmodule SamplePhxWeb.VideoControllerTest do
  use SamplePhxWeb.ConnCase, async: true

  alias SamplePhx.Multimedia

  setup args do
    cond do
      args[:login_as] ->
        user = user_fixture(username: args[:login_as])
        conn = assign(args[:conn], :current_user, user)

        {:ok, conn: conn, user: user}

      true ->
        {:ok, conn: args[:conn]}
    end
  end

  @tag login_as: nil
  test "requires user authentication on all actions", %{conn: conn} do
    Enum.each(
      [
        get(conn, Routes.video_path(conn, :new)),
        get(conn, Routes.video_path(conn, :index)),
        get(conn, Routes.video_path(conn, :show, "123")),
        get(conn, Routes.video_path(conn, :edit, "123")),
        get(conn, Routes.video_path(conn, :update, "123", %{})),
        get(conn, Routes.video_path(conn, :create, %{})),
        get(conn, Routes.video_path(conn, :delete, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end

  @tag login_as: "sneaky"
  test "authorizes actions against access by other users", %{conn: conn, user: _} do
    video = video_fixture(user_fixture(username: "owner"))

    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :show, video))
    end

    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :edit, video))
    end

    assert_error_sent :not_found, fn ->
      put(conn, Routes.video_path(conn, :update, video, video: %{title: "Updated Title"}))
    end

    assert_error_sent :not_found, fn ->
      get(conn, Routes.video_path(conn, :delete, video))
    end
  end

  describe "index" do
    @tag login_as: "jose"
    test "lists all videos the user owns", %{conn: conn, user: user} do
      user_video = video_fixture(user, title: "Funny Code")
      other_video = video_fixture(user_fixture(username: "other"), title: "Another Video")

      conn = get(conn, Routes.video_path(conn, :index))

      response = html_response(conn, 200)
      assert response =~ "Listing Videos"
      assert response =~ user_video.title
      refute response =~ other_video.title
    end
  end

  describe "new" do
    @tag login_as: "jose"
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.video_path(conn, :new))
      assert html_response(conn, 200) =~ "New Video"
    end
  end

  describe "create" do
    @valid_attrs %{
      url: "https://youtu.be",
      title: "vid",
      description: "a vid"
    }

    @tag login_as: "jose"
    test "creates user video and redirects to show when data is valid", %{conn: conn, user: user} do
      conn_after_create = post(conn, Routes.video_path(conn, :create), video: @valid_attrs)
      assert %{id: id} = redirected_params(conn_after_create)
      assert redirected_to(conn_after_create) == Routes.video_path(conn_after_create, :show, id)

      conn = get(conn, Routes.video_path(conn, :show, id))

      assert html_response(conn, 200) =~ "Show Video"
      assert Multimedia.get_video!(id).user_id == user.id
    end

    @tag login_as: "jose"
    test "renders errors when data is invalid", %{conn: conn} do
      count_before = video_count()

      conn = post(conn, Routes.video_path(conn, :create), video: %{title: "Invalid"})

      assert html_response(conn, 200) =~ "New Video"
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  end

  describe "edit video" do
    @tag login_as: "jose"
    test "renders form for editing chosen video", %{conn: conn, user: user} do
      video = video_fixture(user)

      conn = get(conn, Routes.video_path(conn, :edit, video))

      assert html_response(conn, 200) =~ "Edit Video"
    end
  end

  describe "update video" do
    @tag login_as: "jose"
    test "redirects when data is valid", %{conn: conn, user: user} do
      video = video_fixture(user)

      conn_after_update = put(conn, Routes.video_path(conn, :update, video), video: %{title: "Updated Title"})

      updated_video_path = "/manage/videos/#{video.id}-updated-title"
      assert redirected_to(conn_after_update) == updated_video_path

      conn = get(conn, updated_video_path)
      assert html_response(conn, 200) =~ "Updated Title"
    end

    @tag login_as: "jose"
    test "renders errors when data is invalid", %{conn: conn, user: user} do
      video = video_fixture(user)

      conn = put(conn, Routes.video_path(conn, :update, video), video: %{title: ""})

      assert html_response(conn, 200) =~ "Edit Video"
    end
  end

  describe "delete video" do
    @tag login_as: "jose"
    test "deletes chosen video", %{conn: conn, user: user} do
      video = video_fixture(user)
      count_before = video_count()

      conn = delete(conn, Routes.video_path(conn, :delete, video))

      assert redirected_to(conn) == Routes.video_path(conn, :index)
      assert video_count() == count_before - 1
    end
  end

  defp video_count, do: Enum.count(Multimedia.list_videos())
end
