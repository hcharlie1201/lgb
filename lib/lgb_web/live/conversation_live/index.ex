defmodule LgbWeb.ConversationLive.Index do
  use LgbWeb, :live_view

  alias Lgb.Chatting

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    profile = Lgb.Accounts.User.current_profile(user)

    {:ok,
     socket
     |> assign(:page_title, "Messages")
     |> stream(:conversations, Chatting.list_conversations(profile))}
  end
end
