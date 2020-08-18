defmodule SamplePhxWeb.WatchView do
  use SamplePhxWeb, :view

  @doc """
  Returns the Youtube player ID of the video. Supports a variery of Youtube URL formats.

  ## Examples

      iex> player_id(video)
      123

  """
  def player_id(video) do
    ~r{^.*(?:youtu\.be/|\w+/|v=)(?<id>[^#&?]*)}
    |> Regex.named_captures(video.url)
    |> get_in(["id"])
  end
end
