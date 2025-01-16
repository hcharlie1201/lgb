defmodule LgbWeb.ChatRoomLive.ShowTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.ChattingFixtures
  import Lgb.AccountsFixtures

  describe "Show Chat Room" do
    setup do
      user = user_fixture()
      chat_room = chat_room_fixture()
      message = message_fixture(chat_room, user)
      
      conn = build_conn() |> log_in_user(user)
      
      %{conn: conn, user: user, chat_room: chat_room, message: message}
    end

    test "mounts with chat room data and messages", %{conn: conn, chat_room: chat_room, message: message} do
      {:ok, view, html} = live(conn, ~p"/chat_rooms/#{chat_room}")
      
      assert html =~ "Welcome to chat room #{chat_room.id}"
      assert html =~ message.content
      assert view |> element("#messages-container") |> has_element?()
      assert view |> element("form") |> has_element?()
    end

    test "handles presence joins and leaves", %{conn: conn, chat_room: chat_room, user: user} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")
      
      # Simulate presence join
      send(view.pid, {LgbWeb.Presence, {:join, %{id: user.id, user: user}}})
      html = render(view)
      assert html =~ user.email
      
      # Simulate presence leave
      send(view.pid, {LgbWeb.Presence, {:leave, %{id: user.id, user: user, metas: []}}})
      html = render(view)
      refute html =~ user.email
    end

    test "handles message sending and broadcasting", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")

      message_content = "Hello world"
      
      # Send a message
      view
      |> form("form", %{"message" => %{"content" => message_content}})
      |> render_submit()

      # Simulate broadcast of the message
      message = %{content: message_content, id: "some-id"}
      send(view.pid, %{event: "new_message", payload: message})
      
      html = render(view)
      assert html =~ message_content
    end

    test "updates message form on input change", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")

      message_content = "typing..."
      
      # Change message content
      view
      |> form("form", %{"message" => %{"content" => message_content}})
      |> render_change()

      assert view |> element("form input") |> render() =~ message_content
    end

    test "shows correct number of online users", %{conn: conn, chat_room: chat_room} do
      {:ok, view, html} = live(conn, ~p"/chat_rooms/#{chat_room}")
      
      # Initially should show 0 users
      assert html =~ "There are currently 0 users online"
      
      # Add a user
      user2 = user_fixture()
      send(view.pid, {LgbWeb.Presence, {:join, %{id: user2.id, user: user2}}})
      
      html = render(view)
      assert html =~ "There are currently 1 users online"
    end
  end
end
