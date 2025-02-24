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
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    # Optimize other_profile determination with pattern matching
    other_profile = get_other_profile(conversation, current_profile.id)
    other_profile = Repo.preload(other_profile, [:first_picture, :user])

    # Load messages after marking as read to avoid double updates
    {:ok, unread_messages} = Lgb.Chatting.read_all_messages(other_profile)

    unless Enum.empty?(unread_messages) do
      LgbWeb.Endpoint.broadcast(
        "conversation:#{conversation.id}",
        "messages_read_batch",
        %{messages: Enum.map(unread_messages, &Map.put(&1, :read, true))}
      )
    end

    all_messages =
      Chatting.list_conversation_messages_by_page(conversation.id, socket.assigns.page, @per_page)

    topic = "conversation:#{conversation.id}"
    if connected?(socket), do: LgbWeb.Endpoint.subscribe(topic)

    {:noreply,
     socket
     |> assign(:form, build_message_form(conversation.id, current_profile.id))
     |> assign(current_profile: current_profile)
     |> assign(conversation: conversation)
     |> assign(other_profile: other_profile)
     |> stream(:all_messages, all_messages)
     |> allow_upload(:avatar, accept: ~w(image/*), max_entries: 1)}
  end

  def handle_event("validate", params, socket) do
    form =
      socket.assigns.form.source
      |> Lgb.Chatting.ConversationMessage.typing_changeset(params)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  def handle_event("send", params, socket) do
    params_with_ids =
      Map.merge(params, %{
        "conversation_id" => socket.assigns.conversation.id,
        "profile_id" => socket.assigns.current_profile.id
      })

    result =
      if uploaded_entries(socket, :avatar) != {[], []} do
        consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
          create_message(params_with_ids, socket, %{entry: entry, path: path})
        end)
        |> Enum.at(0)
      else
        create_message(params_with_ids, socket)
      end

    case result do
      {:ok, message} ->
        {:noreply, reset_form(socket, message)}

      %ConversationMessage{} = message ->
        {:noreply, reset_form(socket, message)}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Failed to send message")}
    end
  end

  def handle_event("load_more", _, socket) do
    {:noreply, paginate_message(socket)}
  end

  def handle_info(%{event: "new_message", payload: message}, socket) do
    if message.profile_id == socket.assigns.other_profile.id do
      handle_received_message(message, socket)
    else
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

  def handle_info(%{event: "messages_read_batch", payload: %{messages: messages}}, socket) do
    # Only update messages from current user
    messages_to_update =
      Enum.filter(messages, &(&1.profile_id == socket.assigns.current_profile.id))

    socket =
      Enum.reduce(messages_to_update, socket, fn message, acc ->
        stream_insert(acc, :all_messages, message)
      end)

    {:noreply, socket}
  end

  def handle_info({Presence, {:join, _presence}}, socket) do
    {:noreply, socket}
  end

  def handle_info({Presence, {:leave, _presence}}, socket) do
    {:noreply, socket}
  end

  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"

  # Private helper functions
  defp get_other_profile(conversation, current_profile_id) do
    cond do
      conversation.sender_profile_id == current_profile_id -> conversation.receiver_profile
      conversation.receiver_profile_id == current_profile_id -> conversation.sender_profile
      true -> nil
    end
  end

  defp build_message_form(conversation_id, profile_id) do
    %ConversationMessage{}
    |> ConversationMessage.changeset(%{
      "conversation_id" => conversation_id,
      "profile_id" => profile_id
    })
    |> to_form(id: "conversation-form")
  end

  defp broadcast_new_message(message) do
    message = Repo.preload(message, [:conversation, :profile])

    LgbWeb.Endpoint.broadcast(
      "conversation:#{message.conversation_id}",
      "new_message",
      message
    )
  end

  defp reset_form(socket, message) do
    assign(socket, :form, build_message_form(message.conversation_id, message.profile_id))
  end

  defp handle_received_message(message, socket) do
    case mark_message_as_read(message) do
      {:ok, updated_message} ->
        broadcast_read_status(updated_message)
        {:noreply, stream_insert(socket, :all_messages, updated_message)}

      _ ->
        {:noreply, socket}
    end
  end

  defp mark_message_as_read(message) do
    message
    |> Ecto.Changeset.change(%{read: true})
    |> Repo.update()
  end

  defp broadcast_read_status(message) do
    LgbWeb.Endpoint.broadcast(
      "conversation:#{message.conversation_id}",
      "messages_read",
      message
    )
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

  defp create_message(params, socket, image_upload \\ nil) do
    case Chatting.create_conversation_message(
           %ConversationMessage{},
           params,
           image_upload
         ) do
      {:ok, message} ->
        broadcast_new_message(message)
        {:ok, message}

      {:error, _changeset} ->
        {:error, socket}
    end
  end
end
