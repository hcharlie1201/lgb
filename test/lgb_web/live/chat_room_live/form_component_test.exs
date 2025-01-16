defmodule LgbWeb.ChatRoomLive.FormComponentTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.ChattingFixtures

  describe "Form Component" do
    test "renders form for new chat room", %{conn: conn} do
      chat_room = chat_room_fixture()
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}/edit")
      
      assert has_element?(view, "form#chat_room-form")
      assert has_element?(view, "input[type='number'][name='chat_room[limit]']")
      assert has_element?(view, "button", "Save Chat room")
    end

    test "validates chat room limit", %{conn: conn} do
      chat_room = chat_room_fixture()
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}/edit")

      view
      |> form("#chat_room-form", %{chat_room: %{limit: nil}})
      |> render_change()

      assert has_element?(view, "#chat_room-form")
    end

    test "saves chat room with valid data", %{conn: conn} do
      chat_room = chat_room_fixture()
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}/edit")

      {:ok, _, html} =
        view
        |> form("#chat_room-form", %{chat_room: %{limit: 42}})
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Chat room updated successfully"
    end
  end
end
