defmodule LgbWeb.ProfileLive.SearchTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.ProfilesFixtures

  describe "Profile search" do
    setup [:register_and_log_in_user, :create_profile]

    def create_profile(%{user: user}) do
      attrs = %{
        handle: "test_user",
        age: 25,
        geolocation: %Geo.Point{coordinates: {-122.27652, 37.80574}, srid: 4326}
      }

      {:ok, profile} = Lgb.Profiles.create_profile(user, attrs)
      %{profile: profile}
    end

    test "renders search form", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")
      assert has_element?(view, "form")
    end

    test "has basic search fields", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")

      assert has_element?(view, "form select[name='min_height_cm']")
      assert has_element?(view, "form select[name='max_height_cm']")
      assert has_element?(view, "form input[name='min_age']")
      assert has_element?(view, "form input[name='max_age']")
      assert has_element?(view, "form input[name='min_weight']")
      assert has_element?(view, "form input[name='max_weight']")
    end

    test "shows search form initially", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")
      assert has_element?(view, "#search-profile")
    end

    test "validates age range", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles")

      # Test minimum age validation
      result =
        view
        |> form("#search-profile", %{
          min_age: 10
        })
        |> render_submit()

      assert result =~ "Age must be between 18 and 100"

      # Test maximum age validation
      result =
        view
        |> form("#search-profile", %{"max_age" => "101"})
        |> render_change()

      assert result =~ "Age must be between 18 and 100"

      # Test age order validation
      result =
        view
        |> form("#search-profile", %{"min_age" => "30", "max_age" => "25"})
        |> render_change()

      assert result =~
               "Maximum age must be greater than or equal to minimum age"
    end

    test "validates weight range", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles/")

      # Test minimum weight validation
      result =
        view
        |> form("#search-profile", %{"min_weight" => 0})
        |> render_submit()

      assert result =~ "Weight must be between greater than 0"

      # Test maximum weight validation
      result =
        view
        |> form("#search-profile", %{"max_weight" => "401"})
        |> render_change()

      assert result =~ "Weight must be between less than 400 lbs"

      # Test weight order validation
      result =
        view
        |> form("#search-profile", %{"min_weight" => "200", "max_weight" => "150"})
        |> render_change()

      assert result =~ "Maximum weight must be greater than or equal to minimum weight"
    end
  end
end
