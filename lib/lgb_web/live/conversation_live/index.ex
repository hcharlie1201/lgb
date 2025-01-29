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
     |> assign(:page_title, "Messages")
     |> stream(:conversations, transformed_conversations)}
  end
end
