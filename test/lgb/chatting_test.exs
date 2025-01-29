defmodule Lgb.ChattingTest do
  use Lgb.DataCase

  alias Lgb.Chatting
  import Lgb.ChattingFixtures
  import Lgb.AccountsFixtures
  import Lgb.ProfilesFixtures

  describe "chat_rooms" do
    alias Lgb.Chatting.ChatRoom

    test "list_chat_rooms/0 returns all chat_rooms" do
      chat_room = chat_room_fixture()
      assert Chatting.list_chat_rooms() == [chat_room]
    end

    test "get_chat_room!/1 returns the chat_room with given id" do
      chat_room = chat_room_fixture()
      assert Chatting.get_chat_room!(chat_room.id) == chat_room
    end

    test "create_chat_room/1 with valid data creates a chat_room" do
      valid_attrs = %{description: "some description", limit: 42}

      assert {:ok, %ChatRoom{} = chat_room} = Chatting.create_chat_room(valid_attrs)
      assert chat_room.description == "some description"
      assert chat_room.limit == 42
    end

    test "create_chat_room/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Chatting.create_chat_room(%{})
    end

    test "update_chat_room/2 with valid data updates the chat_room" do
      chat_room = chat_room_fixture()
      update_attrs = %{description: "updated description", limit: 43}

      assert {:ok, %ChatRoom{} = chat_room} = Chatting.update_chat_room(chat_room, update_attrs)
      assert chat_room.description == "updated description"
      assert chat_room.limit == 43
    end

    test "update_chat_room/2 with invalid data returns error changeset" do
      chat_room = chat_room_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Chatting.update_chat_room(chat_room, %{description: nil})

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
    setup do
      chat_room = chat_room_fixture()
      user = user_fixture()
      %{chat_room: chat_room, user: user}
    end

    test "list_messages/1 returns all messages for a chat room", %{
      chat_room: chat_room,
      user: user
    } do
      message = message_fixture(chat_room, user)
      assert Chatting.list_messages(chat_room.id) == [message]
    end

    test "create_message!/1 with valid data creates a message", %{
      chat_room: chat_room,
      user: user
    } do
      valid_attrs = %{content: "some content", chat_room_id: chat_room.id, user_id: user.id}
      message = Chatting.create_message!(valid_attrs)
      assert message.content == "some content"
      assert message.chat_room_id == chat_room.id
      assert message.user_id == user.id
    end
  end

  describe "conversations" do
    setup do
      user1 = user_fixture()
      user2 = user_fixture()
      profile1 = profile_fixture(user1)
      profile2 = profile_fixture(user2)
      %{profile1: profile1, profile2: profile2}
    end

    test "get_or_create_conversation/2 creates new conversation", %{
      profile1: profile1,
      profile2: profile2
    } do
      assert {:ok, conversation} = Chatting.get_or_create_conversation(profile1, profile2)
      assert conversation.sender_profile_id == profile1.id
      assert conversation.receiver_profile_id == profile2.id
    end

    test "get_or_create_conversation/2 returns existing conversation", %{
      profile1: profile1,
      profile2: profile2
    } do
      {:ok, conversation1} = Chatting.get_or_create_conversation(profile1, profile2)
      {:ok, conversation2} = Chatting.get_or_create_conversation(profile1, profile2)
      assert conversation1.id == conversation2.id
    end

    test "list_conversations/1 returns all conversations for a profile", %{
      profile1: profile1,
      profile2: profile2
    } do
      {:ok, conversation} = Chatting.get_or_create_conversation(profile1, profile2)
      assert [loaded_conversation] = Chatting.list_conversations(profile1)
      assert loaded_conversation.id == conversation.id
    end
  end

  describe "conversation_messages" do
    alias Lgb.Chatting.ConversationMessage

    setup do
      user1 = user_fixture()
      user2 = user_fixture()
      profile1 = profile_fixture(user1)
      profile2 = profile_fixture(user2)
      {:ok, conversation} = Chatting.get_or_create_conversation(profile1, profile2)
      %{profile1: profile1, profile2: profile2, conversation: conversation}
    end

    test "create_conversation_message/2 with valid data creates a message",
         %{profile1: profile1, conversation: conversation} do
      valid_attrs = %{
        content: "some content",
        profile_id: profile1.id,
        conversation_id: conversation.id
      }

      assert {:ok, message} =
               Chatting.create_conversation_message(%ConversationMessage{}, valid_attrs)

      assert message.content == "some content"
      assert message.profile_id == profile1.id
      assert message.conversation_id == conversation.id
    end

    test "list_conversation_messages!/2 returns messages for conversation and profile",
         %{profile1: profile1, conversation: conversation} do
      message = conversation_message_fixture(conversation, profile1)
      assert [loaded_message] = Chatting.list_conversation_messages!(conversation.id, profile1.id)
      assert loaded_message.id == message.id
    end
  end
end
