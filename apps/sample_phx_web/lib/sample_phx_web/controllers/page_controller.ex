defmodule SamplePhxWeb.PageController do
  use SamplePhxWeb, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: Routes.user_path(conn, :index))
    else
      render(conn, "index.html")
    end
  end
end
