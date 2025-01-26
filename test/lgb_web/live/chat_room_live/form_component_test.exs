defmodule LgbWeb.ChatRoomLive.FormComponentTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.ChattingFixtures
  import Lgb.AccountsFixtures

  describe "Form Component" do
    setup do
      %{user: user_fixture()}
    end

    test "renders form for new chat room", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      chat_room = chat_room_fixture()
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}/edit")

      assert has_element?(view, "form#chat_room-form")
      assert has_element?(view, "input[type='number'][name='chat_room[limit]']")
      assert has_element?(view, "button", "Save Chat room")
    end

    test "validates chat room limit", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      chat_room = chat_room_fixture()
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}/edit")

      view
      |> form("#chat_room-form", %{chat_room: %{limit: nil}})
      |> render_change()

      assert has_element?(view, "#chat_room-form")
    end
  end
end
