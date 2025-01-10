defmodule Lgb.ChattingTest do
  use Lgb.DataCase

  alias Lgb.Chatting

  describe "chat_rooms" do
    alias Lgb.Chatting.ChatRoom

    import Lgb.ChattingFixtures

    @invalid_attrs %{limit: nil}

    test "list_chat_rooms/0 returns all chat_rooms" do
      chat_room = chat_room_fixture()
      assert Chatting.list_chat_rooms() == [chat_room]
    end

    test "get_chat_room!/1 returns the chat_room with given id" do
      chat_room = chat_room_fixture()
      assert Chatting.get_chat_room!(chat_room.id) == chat_room
    end

    test "create_chat_room/1 with valid data creates a chat_room" do
      valid_attrs = %{limit: 42}

      assert {:ok, %ChatRoom{} = chat_room} = Chatting.create_chat_room(valid_attrs)
      assert chat_room.limit == 42
    end

    test "create_chat_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chatting.create_chat_room(@invalid_attrs)
    end

    test "update_chat_room/2 with valid data updates the chat_room" do
      chat_room = chat_room_fixture()
      update_attrs = %{limit: 43}

      assert {:ok, %ChatRoom{} = chat_room} = Chatting.update_chat_room(chat_room, update_attrs)
      assert chat_room.limit == 43
    end

    test "update_chat_room/2 with invalid data returns error changeset" do
      chat_room = chat_room_fixture()
      assert {:error, %Ecto.Changeset{}} = Chatting.update_chat_room(chat_room, @invalid_attrs)
      assert chat_room == Chatting.get_chat_room!(chat_room.id)
    end

    test "delete_chat_room/1 deletes the chat_room" do
      chat_room = chat_room_fixture()
      assert {:ok, %ChatRoom{}} = Chatting.delete_chat_room(chat_room)
      assert_raise Ecto.NoResultsError, fn -> Chatting.get_chat_room!(chat_room.id) end
    end

    test "change_chat_room/1 returns a chat_room changeset" do
      chat_room = chat_room_fixture()
      assert %Ecto.Changeset{} = Chatting.change_chat_room(chat_room)
    end
  end

  describe "messages" do
    alias Lgb.Chatting.Message

    import Lgb.ChattingFixtures

    @invalid_attrs %{}

    test "list_messages/0 returns all messages" do
      message = message_fixture()
      assert Chatting.list_messages() == [message]
    end

    test "get_message!/1 returns the message with given id" do
      message = message_fixture()
      assert Chatting.get_message!(message.id) == message
    end

    test "create_message/1 with valid data creates a message" do
      valid_attrs = %{}

      assert {:ok, %Message{} = message} = Chatting.create_message(valid_attrs)
    end

    test "create_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chatting.create_message(@invalid_attrs)
    end

    test "update_message/2 with valid data updates the message" do
      message = message_fixture()
      update_attrs = %{}

      assert {:ok, %Message{} = message} = Chatting.update_message(message, update_attrs)
    end

    test "update_message/2 with invalid data returns error changeset" do
      message = message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chatting.update_message(message, @invalid_attrs)
      assert message == Chatting.get_message!(message.id)
    end

    test "delete_message/1 deletes the message" do
      message = message_fixture()
      assert {:ok, %Message{}} = Chatting.delete_message(message)
      assert_raise Ecto.NoResultsError, fn -> Chatting.get_message!(message.id) end
    end

    test "change_message/1 returns a message changeset" do
      message = message_fixture()
      assert %Ecto.Changeset{} = Chatting.change_message(message)
    end
  end

  describe "conversation_messages" do
    alias Lgb.Chatting.ConversationMessage

    import Lgb.ChattingFixtures

    @invalid_attrs %{read: nil, content: nil}

    test "list_conversation_messages/0 returns all conversation_messages" do
      conversation_message = conversation_message_fixture()
      assert Chatting.list_conversation_messages() == [conversation_message]
    end

    test "get_conversation_message!/1 returns the conversation_message with given id" do
      conversation_message = conversation_message_fixture()
      assert Chatting.get_conversation_message!(conversation_message.id) == conversation_message
    end

    test "create_conversation_message/1 with valid data creates a conversation_message" do
      valid_attrs = %{read: true, content: "some content"}

      assert {:ok, %ConversationMessage{} = conversation_message} = Chatting.create_conversation_message(valid_attrs)
      assert conversation_message.read == true
      assert conversation_message.content == "some content"
    end

    test "create_conversation_message/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chatting.create_conversation_message(@invalid_attrs)
    end

    test "update_conversation_message/2 with valid data updates the conversation_message" do
      conversation_message = conversation_message_fixture()
      update_attrs = %{read: false, content: "some updated content"}

      assert {:ok, %ConversationMessage{} = conversation_message} = Chatting.update_conversation_message(conversation_message, update_attrs)
      assert conversation_message.read == false
      assert conversation_message.content == "some updated content"
    end

    test "update_conversation_message/2 with invalid data returns error changeset" do
      conversation_message = conversation_message_fixture()
      assert {:error, %Ecto.Changeset{}} = Chatting.update_conversation_message(conversation_message, @invalid_attrs)
      assert conversation_message == Chatting.get_conversation_message!(conversation_message.id)
    end

    test "delete_conversation_message/1 deletes the conversation_message" do
      conversation_message = conversation_message_fixture()
      assert {:ok, %ConversationMessage{}} = Chatting.delete_conversation_message(conversation_message)
      assert_raise Ecto.NoResultsError, fn -> Chatting.get_conversation_message!(conversation_message.id) end
    end

    test "change_conversation_message/1 returns a conversation_message changeset" do
      conversation_message = conversation_message_fixture()
      assert %Ecto.Changeset{} = Chatting.change_conversation_message(conversation_message)
    end
  end
end
