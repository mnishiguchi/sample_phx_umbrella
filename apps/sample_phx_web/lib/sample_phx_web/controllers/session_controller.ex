defmodule SamplePhxWeb.SessionController do
  use SamplePhxWeb, :controller

  def new(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: Routes.user_path(conn, :index))
    else
      render(conn, "new.html")
    end
  end

  def create(conn, %{"session" => %{"username" => username, "password" => password}}) do
    case SamplePhx.Accounts.authenticate_by_username_and_password(username, password) do
      {:ok, user} ->
        conn
        |> SamplePhxWeb.Auth.login(user)
        |> put_flash(:info, "Welcome back")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "Invalid username/password combination")
        |> render("new.html")
    end
  end

  def delete(conn, _params) do
    conn
    |> SamplePhxWeb.Auth.logout()
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
