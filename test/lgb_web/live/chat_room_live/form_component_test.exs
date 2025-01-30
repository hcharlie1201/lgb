defmodule LgbWeb.ChatRoomLive.FormComponentTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.ChattingFixtures
  import Lgb.AccountsFixtures

  describe "Form Component" do
    setup do
      user = user_fixture()
      chat_room = chat_room_fixture()
      %{user: user, chat_room: chat_room}
    end
  end
end
