defmodule Lgb.ChattingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Chatting` context.
  """

  alias Lgb.Chatting

  def chat_room_fixture(attrs \\ %{}) do
    {:ok, chat_room} =
      attrs
      |> Enum.into(%{
        description: "some description",
        limit: 42
      })
      |> Chatting.create_chat_room()

    chat_room
  end

  def message_fixture(chat_room, profile, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        content: "some content",
        chat_room_id: chat_room.id,
        profile_id: profile.id
      })

    Chatting.create_message!(attrs)
  end

  def conversation_message_fixture(conversation, profile, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        "content" => "some content",
        "profile_id" => profile.id,
        "conversation_id" => conversation.id
      })

    {:ok, message} = Chatting.create_conversation_message(%Chatting.ConversationMessage{}, attrs)
    message
  end

  def create_conversation_with_messages(profile1, profile2, message_count) do
    {:ok, conversation} = Chatting.get_or_create_conversation(profile1, profile2)

    Enum.each(1..message_count, fn _ ->
      conversation_message_fixture(conversation, profile2)
    end)

    conversation
  end
end
