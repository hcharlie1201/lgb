defmodule Lgb.Chatting do
  @moduledoc """
  The Chatting context.
  """

  import Ecto.Query, warn: false
  alias Expo.Message
  alias Lgb.Repo

  alias Lgb.Chatting.ChatRoom

  @doc """
  Returns the list of chat_rooms.

  ## Examples

      iex> list_chat_rooms()
      [%ChatRoom{}, ...]

  """
  def list_chat_rooms do
    Repo.all(ChatRoom)
  end

  @doc """
  Gets a single chat_room.

  Raises `Ecto.NoResultsError` if the Chat room does not exist.

  ## Examples

      iex> get_chat_room!(123)
      %ChatRoom{}

      iex> get_chat_room!(456)
      ** (Ecto.NoResultsError)

  """
  def get_chat_room!(id), do: Repo.get!(ChatRoom, id)

  @doc """
  Creates a chat_room.

  ## Examples

      iex> create_chat_room(%{field: value})
      {:ok, %ChatRoom{}}

      iex> create_chat_room(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_chat_room(attrs \\ %{}) do
    %ChatRoom{}
    |> ChatRoom.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a chat_room.

  ## Examples

      iex> update_chat_room(chat_room, %{field: new_value})
      {:ok, %ChatRoom{}}

      iex> update_chat_room(chat_room, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_chat_room(%ChatRoom{} = chat_room, attrs) do
    chat_room
    |> ChatRoom.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a chat_room.

  ## Examples

      iex> delete_chat_room(chat_room)
      {:ok, %ChatRoom{}}

      iex> delete_chat_room(chat_room)
      {:error, %Ecto.Changeset{}}

  """
  def delete_chat_room(%ChatRoom{} = chat_room) do
    Repo.delete(chat_room)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking chat_room changes.

  ## Examples

      iex> change_chat_room(chat_room)
      %Ecto.Changeset{data: %ChatRoom{}}

  """
  def change_chat_room(%ChatRoom{} = chat_room, attrs \\ %{}) do
    ChatRoom.changeset(chat_room, attrs)
  end

  alias Lgb.Chatting.Message

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages()
      [%Message{}, ...]

  """
  def list_messages(chat_room_id) do
    query =
      from m in Message,
        where: m.chat_room_id == ^chat_room_id,
        order_by: [asc: m.inserted_at]

    query
    |> Lgb.Repo.all()
    |> Lgb.Repo.preload(:profile)
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(123)
      %Message{}

      iex> get_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(id), do: Repo.get!(Message, id)

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(%{field: value})
      {:ok, %Message{}}

      iex> create_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message!(attrs \\ %{}) do
    %Message{}
    |> Message.changeset(attrs)
    |> Repo.insert!()
  end

  @doc """
  Updates a message.

  ## Examples

      iex> update_message(message, %{field: new_value})
      {:ok, %Message{}}

      iex> update_message(message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_message(%Message{} = message, attrs) do
    message
    |> Message.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a message.

  ## Examples

      iex> delete_message(message)
      {:ok, %Message{}}

      iex> delete_message(message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_message(%Message{} = message) do
    Repo.delete(message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Message{} = message, attrs \\ %{}) do
    Message.changeset(message, attrs)
  end

  alias Lgb.Chatting.ConversationMessage

  def list_conversation_messages_by_page(conversation_id, page, per_page) do
    total_messages =
      from(cm in ConversationMessage, where: cm.conversation_id == ^conversation_id)
      |> Repo.aggregate(:count, :id)

    start_offset = max(total_messages - page * per_page, 0)

    query =
      from cm in ConversationMessage,
        where: cm.conversation_id == ^conversation_id,
        # Always sort in ascending order
        order_by: [asc: cm.inserted_at],
        limit: ^per_page,
        offset: ^start_offset,
        preload: [:profile, :conversation]

    Repo.all(query)
  end

  @doc """
  Returns the list of conversation_messages.

  ## Examples

      iex> list_conversation_messages()
      [%ConversationMessage{}, ...]

  """
  def list_conversation_messages!(conversation_id, profile_id) do
    query =
      from cm in ConversationMessage,
        where: cm.conversation_id == ^conversation_id and cm.profile_id == ^profile_id,
        order_by: [asc: cm.inserted_at]

    Repo.all(query)
  end

  def list_conversation_messages!(conversation_id) do
    query =
      from cm in ConversationMessage,
        where: cm.conversation_id == ^conversation_id,
        order_by: [asc: cm.inserted_at],
        preload: [:profile, :conversation]

    Repo.all(query)
  end

  def read_all_messages(profile) do
    unread_messages =
      Lgb.Repo.all(
        from m in Lgb.Chatting.ConversationMessage,
          where: m.profile_id == ^profile.id,
          where: m.read == false,
          order_by: [desc: m.inserted_at],
          preload: [:profile],
          select: m
      )

    # Mark messages as read in a transaction
    Lgb.Repo.transaction(fn ->
      Enum.each(unread_messages, fn message ->
        message
        |> Ecto.Changeset.change(%{read: true})
        |> Lgb.Repo.update!()
      end)

      unread_messages
    end)
  end

  def list_conversation_messages_and_metadata(conversation_id, current_profile_id) do
    conversations = get_conversation(conversation_id)

    conversations
    |> Repo.preload([:conversation_messages])
    |> Enum.map(fn conversation ->
      # Determine which profile is the "other" person
      other_profile =
        case conversation do
          %{sender_profile_id: ^current_profile_id} -> conversation.receiver_profile
          %{receiver_profile_id: ^current_profile_id} -> conversation.sender_profile
        end

      # Preload the other profile's first picture
      other_profile = Repo.get(Profile, other_profile.id) |> Repo.preload(:first_picture)

      # # Separate messages into "my_messages" and "other_messages"
      # {my_messages, other_messages} =
      #   conversation.conversation_messages
      #   |> Enum.split_with(fn message ->
      #     message.sender_profile_id == current_profile_id
      #   end)

      # # Sort messages by inserted_at (most recent first)
      # sorted_my_messages = Enum.sort_by(my_messages, & &1.inserted_at, :desc)
      # sorted_other_messages = Enum.sort_by(other_messages, & &1.inserted_at, :desc)

      # Add metadata to the conversation struct
      conversation
      |> Map.put(:other_profile, other_profile)
    end)
  end

  @doc """
  Gets a single conversation_message.

  Raises `Ecto.NoResultsError` if the Conversation message does not exist.

  ## Examples

      iex> get_conversation_message!(123)
      %ConversationMessage{}

      iex> get_conversation_message!(456)
      ** (Ecto.NoResultsError)

  """
  def get_conversation_message!(id), do: Repo.get!(ConversationMessage, id)

  @doc """
  Creates a conversation_message.

  ## Examples

      iex> create_conversation_message(%{field: value})
      {:ok, %ConversationMessage{}}

      iex> create_conversation_message(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_conversation_message(conversation_message \\ %ConversationMessage{}, attrs \\ %{}) do
    conversation_message
    |> ConversationMessage.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a conversation_message.

  ## Examples

      iex> update_conversation_message(conversation_message, %{field: new_value})
      {:ok, %ConversationMessage{}}

      iex> update_conversation_message(conversation_message, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_conversation_message(%ConversationMessage{} = conversation_message, attrs) do
    conversation_message
    |> ConversationMessage.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a conversation_message.

  ## Examples

      iex> delete_conversation_message(conversation_message)
      {:ok, %ConversationMessage{}}

      iex> delete_conversation_message(conversation_message)
      {:error, %Ecto.Changeset{}}

  """
  def delete_conversation_message(%ConversationMessage{} = conversation_message) do
    Repo.delete(conversation_message)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking conversation_message changes.

  ## Examples

      iex> change_conversation_message(conversation_message)
      %Ecto.Changeset{data: %ConversationMessage{}}

  """
  def change_conversation_message(%ConversationMessage{} = conversation_message, attrs \\ %{}) do
    ConversationMessage.changeset(conversation_message, attrs)
  end

  alias Lgb.Chatting.Conversation
  alias Lgb.Profiles.Profile

  def list_conversations(profile) do
    query =
      from c in Conversation,
        where: c.sender_profile_id == ^profile.id or c.receiver_profile_id == ^profile.id,
        order_by: [asc: c.inserted_at]

    Repo.all(query)
  end

  def count_unread_messages(conversation_id, current_profile_id) do
    from(m in ConversationMessage,
      where: m.conversation_id == ^conversation_id,
      where: m.profile_id != ^current_profile_id,
      where: m.read == false
    )
    |> Repo.aggregate(:count)
  end

  def count_unread_messages(current_profile_id) do
    from(m in ConversationMessage,
      join: c in Conversation,
      on: m.conversation_id == c.id,
      where: m.profile_id != ^current_profile_id,
      where: m.read == false,
      where:
        c.sender_profile_id == ^current_profile_id or c.receiver_profile_id == ^current_profile_id
    )
    |> Repo.aggregate(:count)
  end

  def list_conversations(profile, search_params) do
    search_pattern = "%#{search_params}%"

    from(c in Conversation,
      join: p in Profile,
      on:
        (p.id == c.sender_profile_id and c.receiver_profile_id == ^profile.id) or
          (p.id == c.receiver_profile_id and c.sender_profile_id == ^profile.id),
      where: ilike(p.handle, ^search_pattern),
      order_by: [asc: c.inserted_at],
      preload: [sender_profile: p, receiver_profile: p]
    )
    |> Repo.all()
  end

  def preload_and_transform_conversations(conversations, current_profile_id) do
    conversations
    |> Repo.preload([:sender_profile, :receiver_profile, :conversation_messages])
    |> Enum.map(fn conversation ->
      # Determine which profile is the "other" person
      other_profile =
        case conversation do
          %{sender_profile_id: ^current_profile_id} -> conversation.receiver_profile
          %{receiver_profile_id: ^current_profile_id} -> conversation.sender_profile
        end

      # Add the other_profile to the conversation struct
      other_profile = Repo.get(Profile, other_profile.id) |> Repo.preload(:first_picture)

      last_message =
        conversation.conversation_messages
        |> Enum.sort_by(& &1.inserted_at, :desc)
        |> List.first()

      conversation
      |> Map.put(:other_profile, other_profile)
      |> Map.put(:last_message, last_message)
    end)
    |> Enum.sort_by(
      fn conv ->
        case conv.last_message do
          nil -> DateTime.from_naive!(~N[1970-01-01 00:00:00], "Etc/UTC")
          message -> message.updated_at
        end
      end,
      :desc
    )
  end

  def get_profile_picture(profile) do
    Repo.get(Profile, profile.id) |> Repo.preload(:latest_picture)
  end

  def get_conversation(id) do
    # If it's a UUID string
    case Ecto.UUID.cast(id) do
      {:ok, uuid} ->
        query =
          from c in Conversation,
            where: c.uuid == ^uuid,
            preload: [:sender_profile, :receiver_profile]

        Repo.one(query)

      :error ->
        # Handle invalid UUID format
        nil
    end
  end

  def create_conversation(attrs \\ %{}) do
    %Conversation{}
    |> Conversation.changeset(attrs)
    |> Repo.insert()
  end

  def get_or_create_conversation(current_profile, other_profile) do
    query =
      from c in Conversation,
        where:
          (c.sender_profile_id == ^current_profile.id and
             c.receiver_profile_id == ^other_profile.id) or
            (c.sender_profile_id == ^other_profile.id and
               c.receiver_profile_id == ^current_profile.id),
        preload: [:sender_profile, :receiver_profile]

    case Repo.one(query) do
      nil ->
        current_profile = Repo.preload(current_profile, :user)
        other_profile = Repo.preload(other_profile, :user)

        {:ok, conversation} =
          create_conversation(%{
            sender_profile_id: current_profile.id,
            receiver_profile_id: other_profile.id
          })

        Lgb.Accounts.UserNotifier.deliver_conversation_notification(
          current_profile.user,
          other_profile.user
        )

        {:ok, conversation}

      conversation ->
        {:ok, conversation}
    end
  end
end
