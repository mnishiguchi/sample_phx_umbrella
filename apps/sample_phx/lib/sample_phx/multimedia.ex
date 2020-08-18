defmodule SamplePhx.Multimedia do
  @moduledoc """
  The Multimedia context.
  """

  import Ecto.Query, warn: false
  alias SamplePhx.Repo
  alias __MODULE__.{Video, Category, Annotation}
  alias SamplePhx.Accounts

  @doc """
  Returns the list of videos.

  ## Examples

      iex> list_videos()
      [%Video{}, ...]

  """
  def list_videos do
    Repo.all(Video)
  end

  @doc """
  Gets a single video.

  Raises `Ecto.NoResultsError` if the Video does not exist.

  ## Examples

      iex> get_video!(123)
      %Video{}

      iex> get_video!(456)
      ** (Ecto.NoResultsError)

  """
  def get_video!(id), do: Repo.get!(Video, id)

  @doc """
  Creates a video.

  ## Examples

      iex> create_video(user, %{field: value})
      {:ok, %Video{}}

      iex> create_video(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_video(%Accounts.User{} = user, attrs \\ %{}) do
    %Video{}
    |> Video.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:user, user)
    |> Repo.insert()
  end

  @doc """
  Updates a video.

  ## Examples

      iex> update_video(video, %{field: new_value})
      {:ok, %Video{}}

      iex> update_video(video, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_video(%Video{} = video, attrs) do
    video
    |> Video.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a video.

  ## Examples

      iex> delete_video(video)
      {:ok, %Video{}}

      iex> delete_video(video)
      {:error, %Ecto.Changeset{}}

  """
  def delete_video(%Video{} = video) do
    Repo.delete(video)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking video changes.

  ## Examples

      iex> change_video(video)
      %Ecto.Changeset{data: %Video{}}

  """
  def change_video(%Video{} = video, attrs \\ %{}) do
    Video.changeset(video, attrs)
  end

  def list_user_videos(%Accounts.User{} = user) do
    Video
    |> user_videos_query(user)
    |> Repo.all()
  end

  def get_user_video!(%Accounts.User{} = user, id) do
    Video
    |> user_videos_query(user)
    |> Repo.get!(id)
  end

  # Fetches all the videos with a matching user.
  defp user_videos_query(query, %Accounts.User{id: user_id}) do
    from(v in query, where: v.user_id == ^user_id)
  end

  def list_alphabetical_categories do
    Category
    |> Category.alphabetical()
    |> Repo.all()
  end

  @doc """
  Upserts a category.

  ## Examples

      iex> create_category!(name)
      %Category{}

      iex> create_category!(nil)
      %** (Postgrex.Error) ERROR 23502 (not_null_violation)
  """
  def create_category!(name) do
    Repo.insert!(%Category{name: name}, on_conflict: :nothing)
  end

  @doc """
  Inserts a user's annotation of a given video id.

  ## Examples

      iex> Multimedia.annotate_video(user, 1, %{ body: "nice", at: 100 })
      {:ok, %Annotation{}}
  """
  def annotate_video(%Accounts.User{id: user_id}, video_id, attrs) do
    %Annotation{video_id: video_id, user_id: user_id}
    |> Annotation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns the list of annotations of a video.

  ## Examples

      iex> Multimedia.list_annotations(video)
      [%Annotation{}]
  """
  def list_annotations(%Video{} = video, since_id \\ 0) do
    Repo.all(
      from annotation in Ecto.assoc(video, :annotations),
        where: ^since_id < annotation.id,
        order_by: [asc: annotation.at, asc: annotation.id],
        limit: 500,
        preload: [:user]
    )
  end
end
