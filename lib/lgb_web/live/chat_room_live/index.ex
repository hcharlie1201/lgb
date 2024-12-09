defmodule LgbWeb.ChatRoomLive.Index do
  use LgbWeb, :live_view

  alias Lgb.Chatting
  alias Lgb.Chatting.ChatRoom

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :chat_rooms, Chatting.list_chat_rooms())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Chat room")
    |> assign(:chat_room, Chatting.get_chat_room!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Chat room")
    |> assign(:chat_room, %ChatRoom{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Chat rooms")
    |> assign(:chat_room, nil)
  end

  @impl true
  def handle_info({LgbWeb.ChatRoomLive.FormComponent, {:saved, chat_room}}, socket) do
    {:noreply, stream_insert(socket, :chat_rooms, chat_room)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    chat_room = Chatting.get_chat_room!(id)
    {:ok, _} = Chatting.delete_chat_room(chat_room)

    {:noreply, stream_delete(socket, :chat_rooms, chat_room)}
  end
end
