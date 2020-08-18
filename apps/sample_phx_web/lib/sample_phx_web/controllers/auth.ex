defmodule SamplePhxWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller
  alias SamplePhxWeb.Router.Helpers, as: Routes

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      # If `current_user` is already present in `conn.assigns`, we honor it no matter how it got
      # there. It makes our code more testable.
      user = conn.assigns[:current_user] ->
        put_current_user(conn, user)

      # Look for a user in the database and put it as `current_user` if found.
      user = user_id && SamplePhx.Accounts.get_user(user_id) ->
        put_current_user(conn, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      # Stop any downstream transformations.
      |> halt()
    end
  end

  def login(conn, user) do
    conn
    |> put_current_user(user)
    |> put_session(:user_id, user.id)
    # Tell Plug to send the session cookie back to the client with a different identifier in case
    # an attacker knew by any chance the previous one.
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  @doc """
  Makes `current_user` available in all downstream functions including controllers and views. Also,
  assigns a logged-in user token for the socket.
  """
  defp put_current_user(conn, user) do
    token = Phoenix.Token.sign(conn, "user socket", user.id)

    conn
    |> assign(:current_user, user)
    |> assign(:user_token, token)
  end
end
