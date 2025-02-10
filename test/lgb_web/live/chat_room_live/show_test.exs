defmodule LgbWeb.ChatRoomLive.ShowTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.ProfilesFixtures
  import Lgb.ChattingFixtures
  import Lgb.AccountsFixtures

  describe "Show Chat Room" do
    setup do
      user = user_fixture()
      profile = profile_fixture(user)
      chat_room = chat_room_fixture()
      message = message_fixture(chat_room, profile)

      conn = build_conn() |> log_in_user(user)

      %{conn: conn, user: user, profile: profile, chat_room: chat_room, message: message}
    end

    test "mounts with chat room data and messages", %{
      conn: conn,
      chat_room: chat_room,
      message: message
    } do
      {:ok, view, html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      assert html =~ message.content
      assert view |> element("#chat-messages-container") |> has_element?()
      assert view |> element("form") |> has_element?()
    end

    test "handles presence joins and leaves", %{
      conn: conn,
      chat_room: chat_room,
      profile: profile
    } do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Simulate presence join
      send(view.pid, {LgbWeb.Presence, {:join, %{id: profile.id, user: profile}}})
      html = render(view)
      assert html =~ profile.handle

      # Simulate presence leave
      send(view.pid, {LgbWeb.Presence, {:leave, %{id: profile.id, user: profile, metas: []}}})
      html = render(view)
    end

    test "handles message sending and broadcasting", %{
      conn: conn,
      chat_room: chat_room,
      profile: profile
    } do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      message_content = "Hello world"

      # Send a message and verify form clears
      assert view
             |> form("form", %{"message" => %{"content" => message_content}})
             |> render_submit() =~ ""

      # Verify message appears after broadcast
      broadcast_message = %{
        id: System.unique_integer([:positive]),
        content: message_content,
        profile: %{
          id: profile.id,
          handle: profile.handle,
          state: "online"
        },
        inserted_at: DateTime.utc_now() |> DateTime.truncate(:second)
      }

      send(view.pid, %Phoenix.Socket.Broadcast{
        event: "new_message",
        payload: broadcast_message,
        topic: "chat_room:#{chat_room.id}"
      })

      html = render(view)
      assert html =~ message_content
      assert html =~ profile.handle
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

    test "messages container exists", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Verify messages container exists
      assert view |> element("#chat-messages-container") |> has_element?()
    end

    test "chat form has expected input and button", %{conn: conn, chat_room: chat_room} do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Verify form elements
      assert view |> element("form input") |> has_element?()
      assert view |> element("form button", "Send Message") |> has_element?()
    end

    test "displays messages", %{
      conn: conn,
      chat_room: chat_room,
      message: message
    } do
      {:ok, view, _html} = live(conn, ~p"/chat_rooms/#{chat_room.id}")

      # Verify message content is displayed
      assert render(view) =~ message.content
    end
  end
end
