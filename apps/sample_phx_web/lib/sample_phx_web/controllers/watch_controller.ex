defmodule SamplePhxWeb.WatchController do
  use SamplePhxWeb, :controller

  alias SamplePhx.Multimedia

  def show(conn, %{"id" => id}) do
    video = Multimedia.get_video!(id)
    render(conn, "show.html", video: video)
  end
end
