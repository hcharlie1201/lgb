defmodule LgbWeb.ChatRoomLive.ShowTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.ChattingFixtures
  import Lgb.AccountsFixtures

  describe "Show Chat Room" do
    setup do
      user = user_fixture()
      chat_room = chat_room_fixture()
      
      %{user: user, chat_room: chat_room}
    end

    test "mounts with chat room data", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")
      
      assert view.assigns.chat_room.id == chat_room.id
      assert view.assigns.form != nil
    end

    test "handles presence joins", %{conn: conn, chat_room: chat_room, user: user} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")
      
      # Simulate presence join
      send(view.pid, {LgbWeb.Presence, {:join, %{id: user.id, metas: [%{phx_ref: "123"}]}}})
      
      assert has_element?(view, "[data-role='presence-list']")
    end

    test "handles message sending", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")

      view
      |> form("#message-form", %{message: %{content: "Hello world"}})
      |> render_submit()

      assert has_element?(view, "[data-role='message']", "Hello world")
    end

    test "validates message content", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")

      view
      |> form("#message-form", %{message: %{content: ""}})
      |> render_change()

      assert has_element?(view, "[data-role='message-error']")
    end
  end
end
