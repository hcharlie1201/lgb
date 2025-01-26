defmodule LgbWeb.ProfileLive.SearchTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.ProfilesFixtures

  describe "Profile search" do
    setup :register_and_log_in_user

    test "renders search form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles/search")
      assert has_element?(view, "form")
    end
  end
end
