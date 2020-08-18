defmodule SamplePhx.MultimediaTest do
  use SamplePhx.DataCase, async: true

  alias SamplePhx.Multimedia
  alias Multimedia.{Video, Category}

  describe "categories" do
    test "list_alphabetical_categories/0" do
      for name <- ~w(Drama Action Comedy) do
        Multimedia.create_category!(name)
      end

      alphabetical_names =
        for %Category{name: name} <- Multimedia.list_alphabetical_categories() do
          name
        end

      assert alphabetical_names == ~w(Action Comedy Drama)
    end
  end

  describe "videos" do
    @valid_attrs %{
      description: "some description",
      title: "some title",
      url: "https://example.com"
    }
    @invalid_attrs %{description: nil, title: nil, url: nil}

    test "list_videos/0 returns all videos" do
      owner = user_fixture()

      %Video{id: id1} = video_fixture(owner)
      assert [%Video{id: ^id1}] = Multimedia.list_videos()

      %Video{id: id2} = video_fixture(owner)
      assert [%Video{id: ^id1}, %Video{id: ^id2}] = Multimedia.list_videos()
    end

    test "get_video!/1 returns the video with given id" do
      owner = user_fixture()
      %Video{id: id} = video_fixture(owner)
      assert %Video{id: ^id} = Multimedia.get_video!(id)
    end

    test "create_video/1 with valid data creates a video" do
      owner = user_fixture()
      assert {:ok, %Video{} = video} = Multimedia.create_video(owner, @valid_attrs)
      assert video.description == "some description"
      assert video.title == "some title"
      assert video.url == "https://example.com"
    end

    test "create_video/1 with invalid data returns error changeset" do
      owner = user_fixture()
      assert {:error, %Ecto.Changeset{}} = Multimedia.create_video(owner, @invalid_attrs)
    end

    test "update_video/2 with valid data updates the video" do
      owner = user_fixture()
      video = video_fixture(owner)
      assert {:ok, %Video{} = video} = Multimedia.update_video(video, %{title: "Updated Title"})
      assert video.title == "Updated Title"
    end

    test "update_video/2 with invalid data returns error changeset" do
      owner = user_fixture()
      %Video{id: id} = video = video_fixture(owner)
      assert {:error, %Ecto.Changeset{}} = Multimedia.update_video(video, @invalid_attrs)
      assert %Video{id: id} = Multimedia.get_video!(id)
    end

    test "delete_video/1 deletes the video" do
      owner = user_fixture()
      video = video_fixture(owner)
      assert {:ok, %Video{}} = Multimedia.delete_video(video)
      assert_raise Ecto.NoResultsError, fn -> Multimedia.get_video!(video.id) end
    end

    test "change_video/1 returns a video changeset" do
      owner = user_fixture()
      video = video_fixture(owner)
      assert %Ecto.Changeset{} = Multimedia.change_video(video)
    end
  end
end
