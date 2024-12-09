defmodule Lgb.MessagingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Messaging` context.
  """

  @doc """
  Generate a conversation.
  """
  def conversation_fixture(attrs \\ %{}) do
    {:ok, conversation} =
      attrs
      |> Enum.into(%{

      })
      |> Lgb.Messaging.create_conversation()

    conversation
  end
end
