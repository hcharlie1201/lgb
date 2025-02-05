defmodule LgbWeb.ConversationLive.Show do
  alias Lgb.Chatting.ConversationMessage
  alias Lgb.Repo
  use LgbWeb, :live_view
  @per_page 20

  alias Lgb.Chatting

  def mount(_params, _session, socket) do
    socket = socket |> assign(:page, 1)
    {:ok, socket}
  end

  def handle_params(%{"id" => id}, _url, socket) do
    conversation = Chatting.get_conversation(id)
    current_user = socket.assigns.current_user
    current_profile = Lgb.Accounts.User.current_profile(current_user)

    # Determine the "other profile" (the person the current user is chatting with)
    other_profile =
      cond do
        conversation.sender_profile_id == current_profile.id -> conversation.receiver_profile
        conversation.receiver_profile_id == current_profile.id -> conversation.sender_profile
        # Handle the case where the current user is not part of the conversation
        true -> nil
      end

    other_profile = Repo.preload(other_profile, [:first_picture, :user])

    all_messages =
      Chatting.list_conversation_messages_by_page(conversation.id, socket.assigns.page, @per_page)

    # gotta subscribe brotha
    LgbWeb.Endpoint.subscribe("conversation:#{id}")

    {:noreply,
     socket
     |> assign(
       form:
         to_form(
           ConversationMessage.changeset(%ConversationMessage{}, %{
             "conversation_id" => conversation.id,
             "profile_id" => current_profile.id
           }),
           id: "conversation-form"
         )
     )
     |> assign(
       conversation_message:
         ConversationMessage.changeset(%ConversationMessage{}, %{
           "conversation_id" => conversation.id,
           "profile_id" => current_profile.id
         })
     )
     |> assign(conversation: conversation)
     |> assign(other_profile: other_profile)
     |> stream(:all_messages, all_messages)}
  end

  def handle_event("validate", params, socket) do
    form =
      socket.assigns.conversation_message
      |> Lgb.Chatting.ConversationMessage.changeset(params)
      |> to_form(action: :validate)

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("send", params, socket) do
    case Chatting.create_conversation_message(socket.assigns.conversation_message, params) do
      {:ok, message} ->
        message = Repo.preload(message, [:conversation, :profile])

        # also broadcast when users are not in the same liveview process
        LgbWeb.Endpoint.broadcast(
          "conversation:#{message.conversation_id}",
          "new_message",
          message
        )

        {:noreply,
         socket
         |> assign(
           form:
             to_form(
               ConversationMessage.changeset(%ConversationMessage{}, %{
                 "conversation_id" => message.conversation_id,
                 "profile_id" => message.profile_id
               })
             )
         )}

      _ ->
        {:error, socket}
    end
  end

  def handle_event("load_more", _, socket) do
    {:noreply, paginate_message(socket)}
  end

  defp paginate_message(socket) do
    socket =
      socket
      |> update(:page, &(&1 + 1))

    previous_messages =
      Chatting.list_conversation_messages_by_page(
        socket.assigns.conversation.id,
        socket.assigns.page,
        @per_page
      )

    socket = stream(socket, :all_messages, previous_messages, at: 0)
    socket
  end

  def handle_info(%{event: "new_message", payload: message}, socket) do
    {:noreply, stream_insert(socket, :all_messages, message)}
  end
end
