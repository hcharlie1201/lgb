defmodule LgbWeb.ChatRoomLive.Show do
  alias LgbWeb.Presence
  use LgbWeb, :live_view
  require Logger

  alias Lgb.Chatting

  def render(assigns) do
    ~H"""
    <ul id="users-online" phx-update="stream">
      <li :for={{dom_id, %{id: id, metas: metas, user: user}} <- @streams.presences} id={dom_id}>
        <%= id %> (<%= user.email %>)
      </li>
    </ul>
    """
  end

  def mount(%{"id" => id}, _session, socket) do
    socket = stream(socket, :presences, [])
    topic = "chat_room:#{id}"

    # Assign page title and chat room details
    chat_room = Chatting.get_chat_room!(id)
    socket = assign(socket, :page_title, "Show Chat Room")
    socket = assign(socket, :chat_room, chat_room)

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
end
