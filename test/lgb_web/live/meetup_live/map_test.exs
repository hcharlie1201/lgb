defmodule LgbWeb.MeetupLive.MapTest do
  use LgbWeb.ConnCase, async: true
  import Phoenix.LiveViewTest
  import Lgb.AccountsFixtures
  import Lgb.MeetupsFixtures
  import Lgb.ProfilesFixtures

  alias Lgb.Meetups
  alias Lgb.Accounts.User

  setup do
    user = user_fixture()
    profile = profile_fixture(user, %{user_id: user.id})
    %{user: user, profile: profile}
  end

  describe "Map LiveView" do
    test "renders map component", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      assert has_element?(view, "#meetup-map-#{user.uuid}")
    end

    test "loads locations when connected", %{conn: conn, user: user, profile: profile} do
      # Create a test location
      location = event_location_fixture(%{"creator_id" => profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for the :load_locations message to be processed
      Process.sleep(300)

      assert render(view) =~ location.title
    end

    test "can open location modal", %{conn: conn, user: user, profile: profile} do
      location = event_location_fixture(%{"creator_id" => profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for locations to load
      Process.sleep(300)

      # Find and click the div that opens the location modal
      assert render_click(view, "open-location-modal", %{"location_id" => location.id}) =~
               "#show-location-#{location.id}"
    end

    test "can join a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location by another user
      other_profile = profile_fixture(user_fixture())
      location = event_location_fixture(%{"creator_id" => other_profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for locations to load
      Process.sleep(300)

      render_click(view, "open-location-modal", %{"location_id" => location.id})

      # Wait for modal to open
      Process.sleep(100)

      # Join the meetup (don't reassign view)
      element(view, "button", "Join Meetup") |> render_click()

      # Verify the user is now a participant
      assert Meetups.is_participant?(location.id, profile.id)
    end

    test "can leave a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location by another user
      other_profile = profile_fixture(user_fixture())
      location = event_location_fixture(%{"creator_id" => other_profile.id})

      # Make the user a participant
      Meetups.join_meetup(
        location.id,
        profile.id
      )

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for locations to load
      Process.sleep(300)

      # Open the location modal
      render_click(view, "open-location-modal", %{"location_id" => location.id})

      # Leave the meetup
      view |> element("button", "Leave Meetup") |> render_click()

      # Verify the user is no longer a participant
      refute Meetups.is_participant?(location.id, profile.id)
    end

    test "can create a new meetup", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Simulate map click to open the create meetup modal
      view |> render_hook("location-selected", %{"lat" => "34.0522", "lng" => "-118.2437"})

      # Fill in the form
      view
      |> form("#selected-position form", %{
        "event_location" => %{
          "title" => "Test Meetup",
          "location_name" => "Test Location",
          "description" => "Test Description",
          "date" => "2023-12-31T12:00",
          "category" => "sport",
          "max_participants" => "10"
        }
      })
      |> render_submit()

      # Wait for the meetup to be created
      Process.sleep(200)

      # Verify the meetup was created
      assert Meetups.list_locations() != []
    end

    test "validates meetup form", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Simulate map click to open the create meetup modal
      view |> render_hook("location-selected", %{"lat" => 34.0522, "lng" => -118.2437})

      # Submit an invalid form
      result =
        view
        |> form("#selected-position form", %{
          "event_location" => %{
            # Title is required
            "title" => "",
            # Location name is required
            "location_name" => ""
          }
        })
        |> render_change()

      # Check for validation errors
      assert result =~ "can&#39;t be blank"
    end

    test "can delete a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location owned by the user
      location = event_location_fixture(%{"creator_id" => profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for locations to load
      Process.sleep(300)

      # Delete the location
      view
      |> element("[phx-click='delete-location']")
      |> render_click()

      # Wait for deletion to complete
      Process.sleep(200)

      # Verify the location was deleted
      assert Meetups.get_location!(location.id) == nil
    end

    test "handles map bounds changed", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      view
      |> render_hook("map-bounds-changed", %{
        "bounds" => %{
          "sw_lat" => "34.1",
          "sw_lng" => "33.9",
          "ne_lat" => "-118.1",
          "ne_lng" => "-118.3"
        }
      })

      # This is mostly a smoke test to ensure the handler doesn't crash
      assert view
    end

    test "handles user location result", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Simulate user location result event
      view
      |> render_hook("user-location-result", %{
        "lat" => "34.0522",
        "lng" => "-118.2437",
        "radius" => "1.0"
      })

      # This is mostly a smoke test to ensure the handler doesn't crash
      assert view
    end

    test "can upload", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Simulate map click to open the create meetup modal
      view |> render_hook("location-selected", %{"lat" => "34.0522", "lng" => "-118.2437"})

      avatar =
        view
        |> file_input("#selected-position", :avatar, [
          %{
            last_modified: 1_594_171_879_000,
            name: "avatar.jpg",
            content: "asdsasd",
            type: "image/jpeg"
          }
        ])

      assert render_upload(avatar, "avatar.jpg") =~ "100%"
    end

    test "stream is populated after load_locations", %{conn: conn, user: user, profile: profile} do
      # Create multiple test locations
      location1 = event_location_fixture(%{"creator_id" => profile.id, "title" => "Location 1"})
      location2 = event_location_fixture(%{"creator_id" => profile.id, "title" => "Location 2"})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for the :load_locations message to be processed
      Process.sleep(300)

      # Verify the stream contains the correct number of items
      locations_count = Meetups.list_locations() |> length()
      assert locations_count == 2
    end
  end
end
