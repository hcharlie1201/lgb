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
      assert chat_room in Chatting.list_chat_rooms()
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
      profile = profile_fixture(user)
      %{chat_room: chat_room, user: user, profile: profile}
    end

    test "list_messages/1 returns all messages for a chat room", %{
      chat_room: chat_room,
      profile: profile
    } do
      message = message_fixture(chat_room, profile)
      assert chat_room in Chatting.list_chat_rooms()
    end

    test "create_message!/1 with valid data creates a message", %{
      chat_room: chat_room,
      user: user,
      profile: profile
    } do
      valid_attrs = %{content: "some content", chat_room_id: chat_room.id, profile_id: profile.id}
      message = Chatting.create_message!(valid_attrs)
      assert message.content == "some content"
      assert message.chat_room_id == chat_room.id
      assert message.profile_id == profile.id
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
        "content" => "some content",
        "profile_id" => profile1.id,
        "conversation_id" => conversation.id
      }

      assert {:ok, message} =
               Chatting.create_conversation_message(%ConversationMessage{}, valid_attrs)

      assert message.content == "some content"
      assert message.profile_id == profile1.id
      assert message.conversation_id == conversation.id
      assert message.uuid != nil
      assert message.read == false
    end

    test "create_conversation_message/2 with invalid data returns error changeset",
         %{profile1: profile1, conversation: conversation} do
      # Missing both content and image
      invalid_attrs = %{
        "profile_id" => profile1.id,
        "conversation_id" => conversation.id
      }

      assert {:error, %Ecto.Changeset{}} =
               Chatting.create_conversation_message(%ConversationMessage{}, invalid_attrs)
    end

    test "create_conversation_message/2 with missing required fields returns error changeset",
         %{conversation: conversation} do
      # Missing profile_id
      invalid_attrs = %{
        "content" => "some content",
        "conversation_id" => conversation.id
      }

      assert {:error, %Ecto.Changeset{}} =
               Chatting.create_conversation_message(%ConversationMessage{}, invalid_attrs)
    end

    test "list_conversation_messages!/2 returns messages for conversation and profile",
         %{profile1: profile1, conversation: conversation} do
      message = conversation_message_fixture(conversation, profile1)
      assert [loaded_message] = Chatting.list_conversation_messages!(conversation.id, profile1.id)
      assert loaded_message.id == message.id
    end

    test "list_conversation_messages_by_page/3 returns paginated messages",
         %{profile1: profile1, conversation: conversation} do
      # Create 15 messages
      Enum.each(1..15, fn _ ->
        conversation_message_fixture(conversation, profile1)
      end)

      # Get first page (10 messages)
      messages = Chatting.list_conversation_messages_by_page(conversation.id, 1, 10)
      assert length(messages) == 10

      # Get second page (5 messages)
      messages = Chatting.list_conversation_messages_by_page(conversation.id, 2, 10)
      assert length(messages) == 5
    end

    test "count_unread_messages/2 returns correct count for conversation",
         %{profile1: profile1, profile2: profile2, conversation: conversation} do
      # Create 3 unread messages from profile2 to profile1
      Enum.each(1..3, fn _ ->
        conversation_message_fixture(conversation, profile2)
      end)

      assert Chatting.count_unread_messages(conversation.id, profile1.id) == 3
    end

    test "count_all_unread_conversation_messages/1 returns total unread across all conversations",
         %{profile1: profile1, profile2: profile2} do
      # Create two conversations
      {:ok, conv1} = Chatting.get_or_create_conversation(profile1, profile2)
      user3 = Lgb.AccountsFixtures.user_fixture()
      profile3 = Lgb.ProfilesFixtures.profile_fixture(user3)
      {:ok, conv2} = Chatting.get_or_create_conversation(profile1, profile3)

      # Add unread messages to both conversations
      conversation_message_fixture(conv1, profile2)
      conversation_message_fixture(conv2, profile3)

      assert Chatting.count_all_unread_conversation_messages(profile1) == 2
    end

    test "preload_and_transform_conversations/2 properly transforms conversations",
         %{profile1: profile1, profile2: profile2, conversation: conversation} do
      message = conversation_message_fixture(conversation, profile2)

      [transformed] = Chatting.preload_and_transform_conversations([conversation], profile1.id)

      assert transformed.other_profile.id == profile2.id
      assert transformed.last_message.id == message.id
    end

    test "list_conversations/2 returns filtered conversations by search term",
         %{profile1: profile1, profile2: profile2} do
      # Update profile2's handle to make it searchable
      {:ok, _} = Lgb.Profiles.update_profile(profile2, %{handle: "searchable_handle"})

      {:ok, _conversation} = Chatting.get_or_create_conversation(profile1, profile2)

      results = Chatting.list_conversations(profile1, "searchable")
      assert length(results) == 1

      results = Chatting.list_conversations(profile1, "nonexistent")
      assert length(results) == 0
    end
  end
end
