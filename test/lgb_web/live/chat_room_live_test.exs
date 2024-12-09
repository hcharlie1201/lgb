defmodule LgbWeb.ChatRoomLiveTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.ChattingFixtures

  @create_attrs %{limit: 42}
  @update_attrs %{limit: 43}
  @invalid_attrs %{limit: nil}

  defp create_chat_room(_) do
    chat_room = chat_room_fixture()
    %{chat_room: chat_room}
  end

  describe "Index" do
    setup [:create_chat_room]

    test "lists all chat_rooms", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/chat_rooms")

      assert html =~ "Listing Chat rooms"
    end

    test "saves new chat_room", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/chat_rooms")

      assert index_live |> element("a", "New Chat room") |> render_click() =~
               "New Chat room"

      assert_patch(index_live, ~p"/chat_rooms/new")

      assert index_live
             |> form("#chat_room-form", chat_room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chat_room-form", chat_room: @create_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chat_rooms")

      html = render(index_live)
      assert html =~ "Chat room created successfully"
    end

    test "updates chat_room in listing", %{conn: conn, chat_room: chat_room} do
      {:ok, index_live, _html} = live(conn, ~p"/chat_rooms")

      assert index_live |> element("#chat_rooms-#{chat_room.id} a", "Edit") |> render_click() =~
               "Edit Chat room"

      assert_patch(index_live, ~p"/chat_rooms/#{chat_room}/edit")

      assert index_live
             |> form("#chat_room-form", chat_room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert index_live
             |> form("#chat_room-form", chat_room: @update_attrs)
             |> render_submit()

      assert_patch(index_live, ~p"/chat_rooms")

      html = render(index_live)
      assert html =~ "Chat room updated successfully"
    end

    test "deletes chat_room in listing", %{conn: conn, chat_room: chat_room} do
      {:ok, index_live, _html} = live(conn, ~p"/chat_rooms")

      assert index_live |> element("#chat_rooms-#{chat_room.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#chat_rooms-#{chat_room.id}")
    end
  end

  describe "Show" do
    setup [:create_chat_room]

    test "displays chat_room", %{conn: conn, chat_room: chat_room} do
      {:ok, _show_live, html} = live(conn, ~p"/chat_rooms/#{chat_room}")

      assert html =~ "Show Chat room"
    end

    test "updates chat_room within modal", %{conn: conn, chat_room: chat_room} do
      {:ok, show_live, _html} = live(conn, ~p"/chat_rooms/#{chat_room}")

      assert show_live |> element("a", "Edit") |> render_click() =~
               "Edit Chat room"

      assert_patch(show_live, ~p"/chat_rooms/#{chat_room}/show/edit")

      assert show_live
             |> form("#chat_room-form", chat_room: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert show_live
             |> form("#chat_room-form", chat_room: @update_attrs)
             |> render_submit()

      assert_patch(show_live, ~p"/chat_rooms/#{chat_room}")

      html = render(show_live)
      assert html =~ "Chat room updated successfully"
    end
  end
end
