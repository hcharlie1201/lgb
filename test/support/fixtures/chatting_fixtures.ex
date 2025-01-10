defmodule Lgb.ChattingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Chatting` context.
  """

  @doc """
  Generate a chat_room.
  """
  def chat_room_fixture(attrs \\ %{}) do
    {:ok, chat_room} =
      attrs
      |> Enum.into(%{
        limit: 42
      })
      |> Lgb.Chatting.create_chat_room()

    chat_room
  end

  @doc """
  Generate a message.
  """
  def message_fixture(attrs \\ %{}) do
    {:ok, message} =
      attrs
      |> Enum.into(%{

      })
      |> Lgb.Chatting.create_message()

    message
  end

  @doc """
  Generate a conversation_message.
  """
  def conversation_message_fixture(attrs \\ %{}) do
    {:ok, conversation_message} =
      attrs
      |> Enum.into(%{
        content: "some content",
        read: true
      })
      |> Lgb.Chatting.create_conversation_message()

    conversation_message
  end
end
