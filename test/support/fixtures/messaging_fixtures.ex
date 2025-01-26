defmodule Lgb.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Messaging` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(sender_profile, receiver_profile, attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{
        sender_profile_id: sender_profile.id,
        receiver_profile_id: receiver_profile.id
      })
      |> Lgb.Chatting.create_conversation()

    conversation
  end
end
