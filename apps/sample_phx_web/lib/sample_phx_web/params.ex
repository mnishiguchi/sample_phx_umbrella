# Implements the Elixir protocol `Phoenix.Param` for the `Multimedia.Video` struct.
defimpl Phoenix.Param, for: SamplePhx.Multimedia.Video do
  @doc """
  Returns a human-friendly ID based on the id and slug of the video.

  ## Examples
      iex> alias SamplePhxWeb.Router.Helpers, as: Routes
      SamplePhxWeb.Router.Helpers

      iex> video = %SamplePhx.Multimedia.Video{id: 1, slug: "hello"}
      %SamplePhx.Multimedia.Video{}

      iex> Routes.watch_path(%URI{}, :show, video)
      "/watch/1-hello"

      iex> url = URI.parse("https://example.com/prefix")
      %URI{}

      iex> Routes.watch_path(url, :show, video)
      "/prefix/watch/1-hello"

      iex> Routes.watch_url(url, :show, video)
      "https://example.com/prefix/watch/1-hello"

  """
  def to_param(%{slug: slug, id: id}) do
    "#{id}-#{slug}"
  end
end
