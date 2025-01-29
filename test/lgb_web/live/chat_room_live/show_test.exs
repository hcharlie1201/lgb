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

    test "mounts with chat room data and messages", %{
      conn: conn,
      chat_room: chat_room,
      message: message
    } do
      {:ok, view, html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      assert html =~ "Welcome to chat room #{chat_room.id}"
      assert html =~ message.content
      assert view |> element("#messages-container") |> has_element?()
      assert view |> element("form") |> has_element?()
    end

    test "handles presence joins and leaves", %{conn: conn, chat_room: chat_room, user: user} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

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
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

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
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      message_content = "typing..."

      # Change message content
      view
      |> form("form", %{"message" => %{"content" => message_content}})
      |> render_change()

      assert view |> element("form input") |> render() =~ message_content
    end

    test "shows correct number of online users", %{conn: conn, chat_room: chat_room} do
      {:ok, view, html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Initially should show 0 users
      assert html =~ "There are currently 0 users online"

      # Add a user
      user2 = user_fixture()
      send(view.pid, {LgbWeb.Presence, {:join, %{id: user2.id, user: user2}}})

      html = render(view)
      assert html =~ "There are currently 1 users online"
    end

    test "renders chat room with proper layout structure", %{conn: conn, chat_room: chat_room} do
      {:ok, _view, html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Verify main layout elements
      assert html =~ ~r/<div class="flex">/
      assert html =~ ~r/<div class="flex-2">/
      assert html =~ ~r/<div class="flex-1 shadow-md outline h-\[400px\] overflow-y-auto"/
    end

    test "messages container has proper styling", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      container = view |> element("#messages-container")
      html = render(container)

      # Verify container styling
      assert html =~ "shadow-md"
      assert html =~ "outline"
      assert html =~ "overflow-y-auto"
      assert html =~ "h-[400px]"
    end

    test "chat form has expected input and button", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Verify form elements
      assert view |> element("form input[label='Chat']") |> has_element?()
      assert view |> element("form button", "Send Message") |> has_element?()
    end

    test "displays messages in proper format", %{
      conn: conn,
      chat_room: chat_room,
      message: message
    } do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      messages_table = view |> element("#messages")
      html = render(messages_table)

      # Verify message display
      assert html =~ message.content
      assert view |> element("#messages-container .table") |> has_element?()
    end
  end
end
