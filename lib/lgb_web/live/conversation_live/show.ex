defmodule LgbWeb.ConversationLive.Show do
  alias Lgb.Chatting.ConversationMessage
  alias Lgb.Repo
  alias LgbWeb.Presence
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
    Lgb.Chatting.read_all_messages(other_profile)

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
     |> assign(current_profile: current_profile)
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

  @doc """
  Handles incoming messages in a chat conversation. This handler has two main scenarios:

  1. When receiving a message from the other person (recipient's view):
    - Marks the message as read in the database
    - Broadcasts the read status back to the sender
    - Shows the message in recipient's chat window

  2. When receiving our own sent message:
    - Simply displays the message in our chat window

  Args:
   - event: "new_message" Phoenix.Socket event
   - payload: The message struct containing content, profile_id, etc
   - socket: The LiveView socket with assigns like current_profile and other_profile

  Examples:

     # Recipient receiving a message:
     handle_info(
       %{event: "new_message", payload: %{profile_id: 2, content: "Hello"}},
       %{assigns: %{other_profile: %{id: 2}}}
     )
     # -> Message marked as read, broadcast read status, show message

     # Sender receiving their own message:
     handle_info(
       %{event: "new_message", payload: %{profile_id: 1, content: "Hi"}},
       %{assigns: %{current_profile: %{id: 1}}}
     )
     # -> Just show message
  """
  def handle_info(%{event: "new_message", payload: message}, socket) do
    if message.profile_id == socket.assigns.other_profile.id do
      # Mark as read since recipient is viewing it
      case message
           |> Ecto.Changeset.change(%{read: true})
           |> Repo.update() do
        {:ok, updated_message} ->
          # Broadcast the read status back to sender
          LgbWeb.Endpoint.broadcast(
            "conversation:#{message.conversation_id}",
            "messages_read",
            updated_message
          )

          # Insert the read message into recipient's stream
          {:noreply, stream_insert(socket, :all_messages, updated_message)}
      end
    else
      # Our own message, just insert it
      {:noreply, stream_insert(socket, :all_messages, message)}
    end
  end

  def handle_info(%{event: "messages_read", payload: message}, socket) do
    # Update sender's UI to show message was read
    if message.profile_id == socket.assigns.current_profile.id do
      {:noreply, stream_insert(socket, :all_messages, message)}
    else
      {:noreply, socket}
    end
  end

  def handle_info({Presence, {:join, _presence}}, socket) do
    {:noreply, socket}
  end

  def handle_info({Presence, {:leave, _presence}}, socket) do
    {:noreply, socket}
  end
end
