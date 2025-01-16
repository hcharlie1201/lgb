defmodule LgbWeb.DashboardLiveTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "Dashboard" do
    test "renders navigation links", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/")

      assert has_element?(view, "a[href='/profiles/current']", "My Profile")
      assert has_element?(view, "a[href='/profiles']", "Search profiles") 
      assert has_element?(view, "a[href='/conversations']", "Inbox/Chats")
      assert has_element?(view, "a[href='/chat_rooms']", "Go to chatroom")
    end
  end
end
