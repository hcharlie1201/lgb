defmodule Lgb.ChattingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Chatting` context.
  """

  alias Lgb.Chatting
  alias Lgb.Profiles

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

  def message_fixture(chat_room, user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        content: "some content",
        chat_room_id: chat_room.id,
        user_id: user.id
      })

    Chatting.create_message!(attrs)
  end

  def profile_fixture(user, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        id: System.unique_integer(),
        handle: "some-handle-#{System.unique_integer()}",
        age: 25,
        height_cm: 170,
        weight_lb: 150,
        city: "some city",
        state: "some state",
        zip: "12345"
      })

    {:ok, profile} = Profiles.create_profile(user, attrs)
    profile
  end

  def conversation_message_fixture(conversation, profile, attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        content: "some content",
        profile_id: profile.id,
        conversation_id: conversation.id
      })

    {:ok, message} = Chatting.create_conversation_message(%Chatting.ConversationMessage{}, attrs)
    message
  end
end
