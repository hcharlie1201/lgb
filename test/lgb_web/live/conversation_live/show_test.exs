defmodule LgbWeb.ConversationLive.ShowTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.AccountsFixtures
  import Lgb.ProfilesFixtures
  import Lgb.MessagingFixtures

  setup do
    user = user_fixture()
    other_user = user_fixture()

    profile = profile_fixture(user)
    profile = profile |> Lgb.Repo.preload(:user)
    other_profile = profile_fixture(other_user)
    other_profile = other_profile |> Lgb.Repo.preload(:user)

    conversation = conversation_fixture(profile, other_profile)

    %{
      user: user,
      profile: profile,
      other_profile: other_profile,
      conversation: conversation
    }
  end

  describe "Show conversation" do
    test "displays conversation with messages", %{
      conn: conn,
      user: user,
      conversation: conversation,
      profile: profile
    } do
      # Create a test message
      message = create_conversation_message(conversation, profile, %{content: "Hello!"})

      {:ok, _view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      assert html =~ "Send"
      assert html =~ message.content
    end

    test "can send new message", %{conn: conn, user: user, conversation: conversation} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      content = "New test message"

      assert view
             |> form("#conversation-form", %{content: content})
             |> render_submit()

      # Wait for the message to be processed
      :timer.sleep(100)

      # Verify the message appears in the view
      assert render(view) =~ content

      # Verify the message was saved to the database
      assert Lgb.Chatting.list_conversation_messages(conversation.id)
             |> Enum.any?(fn msg -> msg.content == content end)
    end

    test "handles message validation", %{conn: conn, user: user, conversation: conversation} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      # Test empty message validation
      assert view
             |> form("#conversation-form", %{content: ""})
             |> render_change() =~ "can&#39;t be blank"
    end

    test "loads more messages on scroll", %{
      conn: conn,
      user: user,
      conversation: conversation,
      profile: profile
    } do
      # Create multiple messages
      Enum.each(1..25, fn i ->
        create_conversation_message(conversation, profile, %{content: "Message #{i}"})
      end)

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      # Initial page should have @per_page messages
      assert view |> render() =~ "Message 25"

      # Load more messages
      assert view
             |> element("#load-more")
             |> render_click()

      # Should now show earlier messages
      assert view |> render() =~ "Message 5"
    end

    test "marks messages as read when viewed", %{
      conn: conn,
      user: user,
      conversation: conversation,
      profile: profile,
      other_profile: other_profile
    } do
      # Create an unread message from other user
      message =
        create_conversation_message(conversation, other_profile, %{
          content: "Unread message",
          read: false
        })

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      # Message should be marked as read after viewing
      # Allow time for async operations
      :timer.sleep(100)
      updated_message = Lgb.Repo.get!(Lgb.Chatting.ConversationMessage, message.id)
      assert updated_message.read
    end

    test "handles image upload", %{conn: conn, user: user, conversation: conversation} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      file_input = %{
        "0" => %{
          last_modified: 1_594_171_879_000,
          name: "test.jpg",
          content:
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
          type: "image/jpeg"
        }
      }

      assert view
             |> file_input("#conversation-form", :avatar, file_input)
             |> render_upload("test.jpg") =~ "100%"
    end

    test "handles empty messages appropriately", %{
      conn: conn,
      user: user,
      conversation: conversation
    } do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      # Try to submit an empty message
      assert view
             |> form("#conversation-form", %{content: ""})
             |> render_submit() =~ "can&#39;t be blank"
    end

    test "handles very long messages", %{conn: conn, user: user, conversation: conversation} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      long_content = String.duplicate("a", 1000)

      assert view
             |> form("#conversation-form", %{content: long_content})
             |> render_submit()

      assert render(view) =~ long_content
    end

    test "updates read status in real-time", %{
      conn: conn,
      user: user,
      conversation: conversation,
      other_profile: other_profile
    } do
      # Create an unread message
      message =
        create_conversation_message(conversation, other_profile, %{
          content: "Test message",
          read: false
        })

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      # Wait for the message to be marked as read
      :timer.sleep(100)

      # Verify the message is marked as read in the database
      updated_message = Lgb.Repo.get!(Lgb.Chatting.ConversationMessage, message.id)
      assert updated_message.read

      # Verify the UI reflects the read status
      html = render(view)
      assert html =~ "Test message"
      assert html =~ "read"
    end

    test "handles image upload successfully", %{
      conn: conn,
      user: user,
      conversation: conversation
    } do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/conversations/#{conversation.uuid}")

      file_input = %{
        "0" => %{
          last_modified: 1_594_171_879_000,
          name: "test.jpg",
          content:
            "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==",
          type: "image/jpeg"
        }
      }

      # Upload the file
      assert view
             |> file_input("#conversation-form", :avatar, file_input)
             |> render_upload("test.jpg") =~ "100%"

      # Submit the form
      assert view
             |> form("#conversation-form", %{})
             |> render_submit()

      # Verify the image was uploaded and appears in the conversation
      :timer.sleep(100)
      html = render(view)
      assert html =~ "test.jpg"
    end
  end

  defp create_conversation_message(conversation, profile, attrs) do
    {:ok, message} =
      Lgb.Chatting.create_conversation_message(
        %Lgb.Chatting.ConversationMessage{},
        Map.merge(attrs, %{
          "conversation_id" => conversation.id,
          "profile_id" => profile.id
        })
      )

    message
  end
end
