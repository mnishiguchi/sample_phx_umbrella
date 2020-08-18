defmodule SamplePhxWeb.AuthTest do
  use SamplePhxWeb.ConnCase, async: true

  alias SamplePhxWeb.Auth
  alias SamplePhx.Accounts.User

  setup %{conn: conn} do
    conn =
      conn
      # Skip fetching the sessions and adding flash message.
      |> bypass_through(SamplePhxWeb.Router, :browser)
      |> get("/")

    {:ok, %{conn: conn}}
  end

  test "authenticate_user halts when no current_user exists", %{conn: conn} do
    conn = Auth.authenticate_user(conn, [])
    assert conn.halted
  end

  test "authenticate_user for existing current_user", %{conn: conn} do
    conn =
      conn
      |> assign(:current_user, %User{})
      |> Auth.authenticate_user([])

    refute conn.halted
  end

  test "login puts the user in the session", %{conn: conn} do
    conn_after_login =
      conn
      |> Auth.login(%User{id: 123})
      |> send_resp(:ok, "")

    # Make sure the user is still in the session.
    session_user_id = get(conn_after_login, "/") |> get_session(:user_id)
    assert session_user_id == 123
  end

  test "logout drops the session", %{conn: conn} do
    conn_after_logout =
      conn
      |> put_session(:user_id, 123)
      |> Auth.logout()
      |> send_resp(:ok, "")

    session_user_id = get(conn_after_logout, "/") |> get_session(:user_id)
    refute session_user_id
  end

  test "call places user from session into assigns", %{conn: conn} do
    user = user_fixture()

    conn =
      conn
      |> put_session(:user_id, user.id)
      |> Auth.call(Auth.init([]))

    assert conn.assigns.current_user.id == user.id
  end

  test "call with no session sets current_user assigns tp nil", %{conn: conn} do
    conn = Auth.call(conn, Auth.init([]))
    assert conn.assigns.current_user == nil
  end
end
