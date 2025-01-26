defmodule LgbWeb.ProfileLive.MyProfileTest do
  use LgbWeb.ConnCase
  import Lgb.AccountsFixtures
  import Phoenix.LiveViewTest

  describe "MyProfile LiveView" do
    setup do
      %{user: user_fixture()}
    end

    test "mounts successfully when signed in", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, html} = live(conn, ~p"/profiles/current")

      assert html =~ "My Pictures"
      assert html =~ "Bio"

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
      assert profile.city == "Test City"
      assert profile.state == "CA"
      assert profile.zip == "12345"
    end

    test "shows error with invalid age", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      profile_params = %{
        "handle" => "TestUser",
        "age" => "15", # Age below 18
        "height_cm" => "170",
        "weight_lb" => "150"
      }

      html = render_submit(view, "update_profile", profile_params)
      assert html =~ "Age must be between 18 and 100"
    end

    test "validates required fields", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      profile_params = %{
        "handle" => "",
        "age" => "",
        "height_cm" => "",
        "weight_lb" => ""
      }

      html = render_submit(view, "update_profile", profile_params)
      assert html =~ "can&#39;t be blank"
    end

    test "validates handle format", %{conn: conn, user: user} do
      conn = log_in_user(conn, user)
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      profile_params = %{
        "handle" => "test@invalid",
        "age" => "25",
        "height_cm" => "170",
        "weight_lb" => "150"
      }

      html = render_submit(view, "update_profile", profile_params)
      assert html =~ "has invalid format"
    end
  end
end
