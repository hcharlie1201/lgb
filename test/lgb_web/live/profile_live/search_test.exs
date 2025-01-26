defmodule LgbWeb.ProfileLive.SearchTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.ProfilesFixtures

  describe "Profile search" do
    setup :register_and_log_in_user

    test "renders search form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")
      assert has_element?(view, "form")
    end

    test "has basic search fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")

      assert has_element?(view, "form input[name='min_height_cm']")
      assert has_element?(view, "form input[name='max_height_cm']")
      assert has_element?(view, "form input[name='min_age']")
      assert has_element?(view, "form input[name='max_age']")
      assert has_element?(view, "form input[name='min_weight']")
      assert has_element?(view, "form input[name='max_weight']")
    end

    test "shows no results initially", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")
      refute has_element?(view, "[id='search-profile']")
    end
  end
end
