defmodule LgbWeb.ConversationLive.Show do
  use LgbWeb, :live_view

  alias Lgb.Chatting

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    conversation = Chatting.get_conversation(id)

    if conversation == nil do
    end

    sender_messages =
      Chatting.list_conversation_messages!(conversation.id, conversation.sender_profile_id)

    receiver_messages =
      Chatting.list_conversation_messages!(conversation.id, conversation.receiver_profile_id)

    {:noreply,
     socket
     |> assign(conversation: conversation)
     |> stream(:sender_messages, sender_messages)
     |> stream(:receiver_messages, receiver_messages)}
  end
end
