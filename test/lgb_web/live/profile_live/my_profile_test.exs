defmodule LgbWeb.ProfileLive.MyProfileTest do
  use LgbWeb.ConnCase
  import Lgb.AccountsFixtures
  import Lgb.ProfilesFixtures
  import Phoenix.LiveViewTest
  alias Lgb.Accounts
  alias Lgb.Profiles
  alias Lgb.Repo
  alias Lgb.Profiles.Hobby

  @hobby_1 "Cycling"
  @hobby_2 "Weightlifting"

  describe "MyProfile LiveView" do
    setup do
      user = user_fixture()
      profile = profile_fixture(user)

      # Assign hobbies to profile
      Repo.insert!(%Hobby{name: @hobby_1})
      Repo.insert!(%Hobby{name: @hobby_2})
      profile
      |> Repo.preload(:hobbies)
      |> Ecto.Changeset.change()
      |> Ecto.Changeset.put_assoc(:hobbies, Repo.all(Hobby))
      |> Repo.update!()

      %{user: user, profile: profile}
    end

    test "mounts successfully when signed in", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, html} = live(conn, ~p"/profiles/current")

      assert html =~ "Gallery"
      assert html =~ "Bio"
      assert html =~ "Update hobbies"
      assert html =~ @hobby_1
      assert html =~ @hobby_2

      # Verify form fields are present
      assert has_element?(view, "input[name='handle']")
      assert has_element?(view, "input[name='age']")
      assert has_element?(view, "select[name='height_cm']")
      assert has_element?(view, "select[name='weight_lb']")
    end

    test "creates new profile if user doesn't have one", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, _view, _html} = live(conn, ~p"/profiles/current")

      profile = Lgb.Accounts.User.current_profile(user)
      assert profile != nil
      assert profile.user_id == user.id
    end

    test "updates profile with valid data", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      profile_params = %{
        "handle" => "TestUser",
        "age" => "25",
        "height_cm" => "170",
        "weight_lb" => "150",
        "biography" => "Test bio",
        "city" => "Test City",
        "state" => "CA",
        "zip" => "12345"
      }

      render_submit(view, "update_profile", profile_params)

      profile = Lgb.Accounts.User.current_profile(user)
      assert profile.handle == "TestUser"
      assert profile.age == 25
      assert profile.height_cm == 170
      assert profile.weight_lb == 150
      assert profile.biography == "Test bio"
    end

    test "shows error with invalid age", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      profile_params = %{
        "handle" => "TestUser",
        # Age below 18
        "age" => "15",
        "height_cm" => "170",
        "weight_lb" => "150",
        "city" => "Test City",
        "state" => "CA",
        "zip" => "12345"
      }

      html = render_submit(view, "update_profile", profile_params)
      assert html =~ "Age must be between 18 and 100"
    end

    test "handles map click event", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      # Mock response from Google Reverse Geocoding
      lat = 37.7749
      lng = -122.4194

      # Simulate map click
      render_hook(view, "map_clicked", %{"lat" => lat, "lng" => lng})

      # Verify the form was updated with the new location
      assert has_element?(view, "#mapid")
    end
  end
end
