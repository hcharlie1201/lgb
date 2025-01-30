defmodule LgbWeb.ChatRoomLive.Show do
  alias LgbWeb.Presence
  use LgbWeb, :live_view
  require Logger

  alias Lgb.Chatting

  def mount(%{"id" => id}, _session, socket) do
    topic = "chat_room:#{id}"
    chat_room = Chatting.get_chat_room!(id)

    # Fetch existing messages from the database
    messages = Chatting.list_messages(id)

    # Need to subscribe to the topic to notify the chatroom so all users can view the message
    LgbWeb.Endpoint.subscribe("chat_room:#{id}")
    presence = Presence.list_online_users(topic)

    socket =
      socket
      |> assign(chat_room: chat_room)
      |> assign(form: to_form(%{}, as: "message"))
      |> stream(:messages, messages)
      |> stream(:presences, presence)

    if connected?(socket) do
      profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
      Presence.track_user(profile.id, topic, profile)
      Presence.subscribe(topic)
    end

    {:ok, socket}
  end

  def handle_info(%Phoenix.Socket.Broadcast{event: "presence_diff", payload: _diff}, socket) do
    {:noreply, socket}
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

  def handle_info(%{event: "new_message", payload: message}, socket) do
    {:noreply, stream_insert(socket, :messages, message)}
  end

  def handle_event("send_message", %{"message" => %{"content" => content}}, socket) do
    chat_room = socket.assigns.chat_room
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    message =
      Chatting.create_message!(%{
        chat_room_id: chat_room.id,
        profile_id: profile.id,
        content: content
      })
      |> Lgb.Repo.preload(:profile)

    LgbWeb.Endpoint.broadcast("chat_room:#{chat_room.id}", "new_message", message)

    socket =
      socket
      |> assign(:form, to_form(%{}, as: "message"))

    {:noreply, socket}
  end

  # do nothing for now but want to filter out messages that are innappropriate
  def handle_event("update_message", %{"message" => %{"content" => content}}, socket) do
    socket = socket |> assign(form: to_form(%{"content" => content}, as: "message"))
    {:noreply, socket}
  end

  def parse_time(given_time) do
    now = DateTime.utc_now()
    diff_in_seconds = DateTime.diff(now, given_time)

    cond do
      diff_in_seconds >= 3600 ->
        hours = div(diff_in_seconds, 3600)
        "#{hours} #{pluralize(hours, "hour")} ago"

      diff_in_seconds >= 60 ->
        minutes = div(diff_in_seconds, 60)
        "#{minutes} #{pluralize(minutes, "minute")} ago"

      true ->
        "just now"
    end
  end

  # Helper function to pluralize the unit (e.g., "hour" vs. "hours")
  defp pluralize(1, unit), do: unit
  defp pluralize(count, unit), do: "#{unit}s"
end
