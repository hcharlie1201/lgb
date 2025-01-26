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

    test "validates age range", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")

      # Test minimum age validation
      view
      |> form("#search-form", %{"min_age" => "15"})
      |> render_change()

      assert has_element?(view, "#search-form .invalid-feedback", "Age must be between 18 and 100")

      # Test maximum age validation
      view
      |> form("#search-form", %{"max_age" => "101"})
      |> render_change()

      assert has_element?(view, "#search-form .invalid-feedback", "Age must be between 18 and 100")

      # Test age order validation
      view
      |> form("#search-form", %{"min_age" => "30", "max_age" => "25"})
      |> render_change()

      assert has_element?(view, "#search-form .invalid-feedback", "Maximum age must be greater than or equal to minimum age")
    end

    test "validates weight range", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")

      # Test minimum weight validation
      view
      |> form("#search-form", %{"min_weight" => "0"})
      |> render_change()

      assert has_element?(view, "#search-form .invalid-feedback", "Weight must be between greater than 0")

      # Test maximum weight validation
      view
      |> form("#search-form", %{"max_weight" => "401"})
      |> render_change()

      assert has_element?(view, "#search-form .invalid-feedback", "Weight must be between less than 400 lbs")

      # Test weight order validation
      view
      |> form("#search-form", %{"min_weight" => "200", "max_weight" => "150"})
      |> render_change()

      assert has_element?(view, "#search-form .invalid-feedback", "Maximum weight must be greater than or equal to minimum age")
    end

    test "navigates to results page on valid search", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")

      {:ok, _view, html} =
        view
        |> form("#search-form", %{
          "min_age" => "25",
          "max_age" => "35",
          "min_weight" => "150",
          "max_weight" => "200"
        })
        |> render_submit()
        |> follow_redirect(conn)

      assert html =~ "Search Results"
    end
  end
end
