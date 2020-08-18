defmodule SamplePhxWeb.VideoViewTest do
  use SamplePhxWeb.ConnCase, async: true
  import Phoenix.View

  alias SamplePhxWeb.VideoView
  alias SamplePhx.{Accounts, Multimedia}
  alias Accounts.User
  alias Multimedia.{Video, Category}

  test "renders index.html", %{conn: conn} do
    videos = [
      %Video{id: "1", title: "dogs"},
      %Video{id: "2", title: "cats"}
    ]

    rendered_content =
      render_to_string(
        VideoView,
        "index.html",
        conn: conn,
        videos: videos
      )

    assert String.contains?(rendered_content, "Listing Videos")

    for video <- videos do
      assert String.contains?(rendered_content, video.title)
    end
  end

  test "renders show.html", %{conn: conn} do
    video = %Video{id: "1", title: "dogs"}

    rendered_content =
      render_to_string(
        VideoView,
        "show.html",
        conn: conn,
        video: video
      )

    assert String.contains?(rendered_content, video.title)
  end

  test "renders new.html", %{conn: conn} do
    _owner = %User{}
    changeset = Multimedia.change_video(%Video{})
    categories = [%Category{id: 123, name: "cats"}]

    rendered_content =
      render_to_string(
        VideoView,
        "new.html",
        conn: conn,
        changeset: changeset,
        # plug :load_categories (for select options)
        categories: categories
      )

    assert String.contains?(rendered_content, "New Video")
  end

  test "renders edit.html", %{conn: conn} do
    video = %Video{id: "1", title: "dogs"}
    changeset = Multimedia.change_video(video)
    categories = [%Category{id: 123, name: "cats"}]

    rendered_content =
      render_to_string(
        VideoView,
        "edit.html",
        conn: conn,
        video: video,
        changeset: changeset,
        # plug :load_categories (for select options)
        categories: categories
      )

    assert String.contains?(rendered_content, "Edit Video")
  end
end
