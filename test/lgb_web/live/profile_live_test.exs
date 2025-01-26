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
    test "displays current user profile form", %{conn: conn} do
      {:ok, edit_live, html} = live(conn, ~p"/profiles/current")
      assert html =~ "Name"

      assert edit_live
             |> form("#my-profile")
             |> has_element?()
    end

    test "updates profile", %{conn: conn} do
      {:ok, edit_live, _html} = live(conn, ~p"/profiles/current")

      assert edit_live
             |> form("#my-profile", profile: @update_attrs)
             |> render_submit()

      html = render(edit_live)
      assert html =~ "some updated handle"
    end

    test "validates profile attributes", %{conn: conn} do
      {:ok, edit_live, _html} = live(conn, ~p"/profiles/current")

      assert edit_live
             |> form("#my-profile", profile: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"
    end
  end
end
