defmodule SamplePhxWeb.PageControllerTest do
  use SamplePhxWeb.ConnCase, async: true

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Welcome to Sample Phx!"
  end
end
