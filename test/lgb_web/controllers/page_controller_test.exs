defmodule LgbWeb.PageControllerTest do
  use LgbWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")

    assert html_response(conn, 200) =~
             "BiBi is the dating app that aims to match bi-sexual men with bi-sexual women"
  end
end
