defmodule LgbWeb.ConversationLiveTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.MessagingFixtures
  import Lgb.AccountsFixtures
  import Lgb.ProfilesFixtures
  alias Lgb.Profiles

  setup do
    user = user_fixture()
    other_user = user_fixture()

    profile = profile_fixture(user)
    other_profile = profile_fixture(other_user)

    conversation = conversation_fixture(profile, other_profile)

    %{
      user: user,
      profile: profile,
      other_profile: other_profile,
      conversation: conversation
    }
  end

  describe "Index" do
    test "lists all conversations", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, _index_live, html} = live(conn, ~p"/conversations")
      assert html =~ "Messages" || html =~ "Inbox"
    end
  end

  describe "Show" do
    test "displays conversation", %{conn: conn, user: user, conversation: conversation} do
      conn = log_in_user(conn, user)
      {:ok, _show_live, html} = live(conn, ~p"/conversations/#{conversation}")
      assert html =~ "Send"
    end

    test "can send message", %{conn: conn, user: user, conversation: conversation} do
      conn = log_in_user(conn, user)
      {:ok, show_live, _html} = live(conn, ~p"/conversations/#{conversation}")

      assert show_live
             |> form("#conversation-form", %{content: "Hello!"})
             |> render_submit()

      html = render(show_live)
      assert html =~ "Hello!"
    end
  end
end
