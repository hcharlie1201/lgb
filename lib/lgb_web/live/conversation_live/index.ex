defmodule LgbWeb.ConversationLive.Index do
  use LgbWeb, :live_view

  alias Lgb.Chatting

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profile = Lgb.Accounts.User.current_profile(user)

    conversations =
      Chatting.list_conversations(profile)

    transformed_conversations =
      Chatting.preload_and_transform_conversations(conversations, profile.id)

    {:ok,
     socket
     |> assign(:search_query, "")
     |> stream(:conversations, transformed_conversations)}
  end

  def handle_event("search", %{"value" => query}, socket) do
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    conversations = Chatting.list_conversations(profile, query)

    transformed_conversations =
      Chatting.preload_and_transform_conversations(conversations, profile.id)

    {:noreply, stream(socket, :conversations, transformed_conversations, reset: true)}
  end
end
