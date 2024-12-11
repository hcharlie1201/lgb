defmodule LgbWeb.ChatRoomLive.Show do
  alias LgbWeb.Presence
  use LgbWeb, :live_view
  require Logger

  alias Lgb.Chatting

  def mount(%{"id" => id}, _session, socket) do
    topic = "chat_room:#{id}"
    socket = stream(socket, :presences, [])
    socket = stream(socket, :messages, Chatting.list_messages(id))

    chat_room = Chatting.get_chat_room!(id)
    socket = assign(socket, :chat_room, chat_room)
    socket = assign(socket, form: to_form(%{}, as: "message"))

    socket =
      if connected?(socket) do
        Presence.track_user(
          socket.assigns.current_user.id,
          topic,
          socket.assigns.current_user
        )

        Presence.subscribe(topic)
        stream(socket, :presences, Presence.list_online_users(topic))
      else
        socket
      end

    {:ok, socket}
  end

  def handle_info({Presence, {:join, presence}}, socket) do
    {:noreply, stream_insert(socket, :presences, presence)}
  end

  def handle_info({Presence, {:leave, presence}}, socket) do
    if presence.metas == [] do
      {:noreply, stream_delete(socket, :presences, presence)}
    else
      {:noreply, stream_insert(socket, :presences, presence)}
    end
  end

  def handle_event("send_message", %{"message" => %{"content" => content}}, socket) do
    chat_room = socket.assigns.chat_room

    Chatting.create_message!(%{
      chat_room_id: chat_room.id,
      user_id: socket.assigns.current_user.id,
      content: content
    })

    socket = assign(socket, form: to_form(%{}, as: "message"))
    {:noreply, socket}
  end

  # do nothing for now but want to filter out messages that are innappropriate
  def handle_event("validate_message", %{"message" => %{"content" => content}}, socket) do
    {:noreply, socket}
  end
end
