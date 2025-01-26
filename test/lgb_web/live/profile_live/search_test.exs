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

    test "has basic search fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles/search")
      
      assert has_element?(view, "form input[name='age_min']")
      assert has_element?(view, "form input[name='age_max']")
      assert has_element?(view, "form input[name='city']")
      assert has_element?(view, "form input[name='state']")
      assert has_element?(view, "form button[type='submit']", "Search")
    end

    test "shows no results initially", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles/search")
      refute has_element?(view, "[data-role='search-results']")
    end
  end
end
