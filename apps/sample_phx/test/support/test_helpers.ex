defmodule SamplePhx.TestHelpers do
  alias SamplePhx.{Accounts, Multimedia}
  alias Accounts.User

  def user_fixture(attrs \\ %{}) do
    default_user_attrs = %{
      name: "Some User",
      username: "user#{System.unique_integer([:positive])}",
      password: attrs[:password] || "password"
    }

    {:ok, user} =
      attrs
      |> Enum.into(default_user_attrs)
      |> Accounts.register_user()

    user
  end

  def video_fixture(%User{} = user, attrs \\ %{}) do
    default_video_attrs = %{
      title: "A Title",
      url: "https://example.com",
      description: "A description"
    }

    {:ok, video} = Multimedia.create_video(user, Enum.into(attrs, default_video_attrs))
    video
  end
end
