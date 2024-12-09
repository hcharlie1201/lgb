defmodule Lgb.MessagingTest do
  use Lgb.DataCase

  alias Lgb.Messaging

  describe "conversations" do
    alias Lgb.Messaging.Conversation

    import Lgb.MessagingFixtures

    @invalid_attrs %{}

    test "list_conversations/0 returns all conversations" do
      conversation = conversation_fixture()
      assert Messaging.list_conversations() == [conversation]
    end

    test "get_conversation!/1 returns the conversation with given id" do
      conversation = conversation_fixture()
      assert Messaging.get_conversation!(conversation.id) == conversation
    end

    test "create_conversation/1 with valid data creates a conversation" do
      valid_attrs = %{}

      assert {:ok, %Conversation{} = conversation} = Messaging.create_conversation(valid_attrs)
    end

    test "create_conversation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Messaging.create_conversation(@invalid_attrs)
    end

    test "update_conversation/2 with valid data updates the conversation" do
      conversation = conversation_fixture()
      update_attrs = %{}

      assert {:ok, %Conversation{} = conversation} = Messaging.update_conversation(conversation, update_attrs)
    end

    test "update_conversation/2 with invalid data returns error changeset" do
      conversation = conversation_fixture()
      assert {:error, %Ecto.Changeset{}} = Messaging.update_conversation(conversation, @invalid_attrs)
      assert conversation == Messaging.get_conversation!(conversation.id)
    end

    test "delete_conversation/1 deletes the conversation" do
      conversation = conversation_fixture()
      assert {:ok, %Conversation{}} = Messaging.delete_conversation(conversation)
      assert_raise Ecto.NoResultsError, fn -> Messaging.get_conversation!(conversation.id) end
    end

    test "change_conversation/1 returns a conversation changeset" do
      conversation = conversation_fixture()
      assert %Ecto.Changeset{} = Messaging.change_conversation(conversation)
    end
  end
end
