defmodule LgbWeb.ProfileLiveTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.AccountsFixtures
  import Lgb.ProfilesFixtures

  @create_attrs %{
    handle: "some handle",
    state: "some state",
    zip: "some zip",
    dob: "2024-12-11",
    height_cm: 42,
    weight_lb: 42,
    city: "some city",
    biography: "some biography"
  }
  @update_attrs %{
    handle: "some updated handle",
    state: "some updated state",
    zip: "some updated zip",
    dob: "2024-12-12",
    height_cm: 43,
    weight_lb: 43,
    city: "some updated city",
    biography: "some updated biography"
  }
  @invalid_attrs %{
    handle: nil,
    state: nil,
    zip: nil,
    dob: nil,
    height_cm: nil,
    weight_lb: nil,
    city: nil,
    biography: nil
  }

  setup do
    user = user_fixture()
    profile = profile_fixture(user)
    conn = log_in_user(build_conn(), user)
    %{user: user, profile: profile, conn: conn}
  end

  describe "Search" do
    test "shows search form", %{conn: conn} do
      {:ok, _index_live, html} = live(conn, ~p"/profiles")
      assert html =~ "Min Height"
      assert html =~ "Max Height"
    end
  end

  describe "Show" do
    test "displays profile", %{conn: conn, profile: profile} do
      {:ok, _show_live, html} = live(conn, ~p"/profiles/#{profile}")
      assert html =~ profile.handle
      assert html =~ profile.city
    end
  end

  describe "My Profile" do
    test "displays current user profile form", %{conn: conn, profile: profile} do
      {:ok, view, html} = live(conn, ~p"/profiles/current")
      
      # Check form exists with correct fields
      assert html =~ "Edit Profile"
      assert has_element?(view, "#my-profile")
      assert has_element?(view, "#my-profile-handle")
      assert has_element?(view, "#my-profile-city")
      
      # Verify current values are shown
      assert html =~ profile.handle
      assert html =~ profile.city
    end

    test "updates profile", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      # Submit form with valid data
      assert view
             |> form("#my-profile", profile: @update_attrs)
             |> render_submit()

      # Wait for the update to process
      :timer.sleep(100)
      
      # Verify changes were applied
      updated_html = render(view)
      assert updated_html =~ @update_attrs.handle
      assert updated_html =~ @update_attrs.city
      assert updated_html =~ "Profile updated successfully"
    end

    test "validates profile attributes", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/profiles/current")

      # Submit invalid data
      html = view
             |> form("#my-profile", profile: @invalid_attrs)
             |> render_change()
      
      # Verify validation errors
      assert html =~ "can&#39;t be blank"
      assert html =~ "Handle can&#39;t be blank"
      assert html =~ "City can&#39;t be blank"
    end
  end
end
