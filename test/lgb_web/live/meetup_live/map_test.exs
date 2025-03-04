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
    profile = profile_fixture(%{user_id: user.id})
    %{user: user, profile: profile}
  end

  describe "Map LiveView" do
    test "renders map component", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      assert has_element?(view, "#meetup-map-#{user.uuid}")
    end

    test "loads locations when connected", %{conn: conn, user: user, profile: profile} do
      # Create a test location
      location = event_location_fixture(%{creator_id: profile.id})
      
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Wait for the :load_locations message to be processed
      Process.sleep(200)
      
      # Check if the location is in the stream
      assert has_element?(view, "[data-location-id='#{location.id}']")
    end

    test "can open location modal", %{conn: conn, user: user, profile: profile} do
      location = event_location_fixture(%{creator_id: profile.id})
      
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Wait for locations to load
      Process.sleep(200)
      
      # Open the location modal
      view |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']") |> render_click()
      
      # Check if modal is displayed
      assert has_element?(view, "#show-location-#{location.id}")
      assert render(view) =~ location.title
    end

    test "can close location modal", %{conn: conn, user: user, profile: profile} do
      location = event_location_fixture(%{creator_id: profile.id})
      
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Wait for locations to load
      Process.sleep(200)
      
      # Open the location modal
      view |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']") |> render_click()
      
      # Close the modal
      view |> element("button", "close") |> render_click()
      
      # Check if modal is closed
      refute has_element?(view, "#show-location-#{location.id}:not(.hidden)")
    end

    test "can join a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location by another user
      other_profile = profile_fixture()
      location = event_location_fixture(%{creator_id: other_profile.id})
      
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Wait for locations to load
      Process.sleep(200)
      
      # Open the location modal
      view |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']") |> render_click()
      
      # Join the meetup
      view |> element("button", "Join Meetup") |> render_click()
      
      # Verify the user is now a participant
      assert Meetups.is_participant?(location.id, profile.id)
      
      # The button should now be "Leave Meetup"
      assert has_element?(view, "button", "Leave Meetup")
    end

    test "can leave a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location by another user
      other_profile = profile_fixture()
      location = event_location_fixture(%{creator_id: other_profile.id})
      
      # Make the user a participant
      Meetups.create_event_participant(%{
        event_location_id: location.id,
        profile_id: profile.id
      })
      
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Wait for locations to load
      Process.sleep(200)
      
      # Open the location modal
      view |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']") |> render_click()
      
      # Leave the meetup
      view |> element("button", "Leave Meetup") |> render_click()
      
      # Verify the user is no longer a participant
      refute Meetups.is_participant?(location.id, profile.id)
      
      # The button should now be "Join Meetup"
      assert has_element?(view, "button", "Join Meetup")
    end

    test "can create a new meetup", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Simulate map click to open the create meetup modal
      view |> render_hook("location-selected", %{"lat" => 34.0522, "lng" => -118.2437})
      
      # Fill in the form
      view
      |> form("#selected-position form", %{
        "event_location" => %{
          "title" => "Test Meetup",
          "location_name" => "Test Location",
          "description" => "Test Description",
          "date" => "2023-12-31T12:00",
          "category" => "social",
          "max_participants" => "10"
        }
      })
      |> render_submit()
      
      # Verify the meetup was created
      assert Meetups.get_location_by_title("Test Meetup") != nil
    end

    test "validates meetup form", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Simulate map click to open the create meetup modal
      view |> render_hook("location-selected", %{"lat" => 34.0522, "lng" => -118.2437})
      
      # Submit an invalid form
      result = view
      |> form("#selected-position form", %{
        "event_location" => %{
          "title" => "",  # Title is required
          "location_name" => "",  # Location name is required
        }
      })
      |> render_change()
      
      # Check for validation errors
      assert result =~ "can&#39;t be blank"
    end

    test "can delete a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location owned by the user
      location = event_location_fixture(%{creator_id: profile.id})
      
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Wait for locations to load
      Process.sleep(200)
      
      # Delete the location
      view |> element("[phx-click='delete-location'][phx-value-id='#{location.id}']") |> render_click()
      
      # Verify the location was deleted
      assert Meetups.get_location(location.id) == nil
    end

    test "handles map bounds changed", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Simulate map bounds changed event
      view |> render_hook("map-bounds-changed", %{
        "bounds" => %{
          "north" => 34.1,
          "south" => 33.9,
          "east" => -118.1,
          "west" => -118.3
        }
      })
      
      # This is mostly a smoke test to ensure the handler doesn't crash
      assert view
    end

    test "handles find nearby", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Simulate find nearby event
      view |> render_hook("find-nearby", %{})
      
      # This is mostly a smoke test to ensure the handler doesn't crash
      assert view
    end

    test "handles user location result", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Simulate user location result event
      view |> render_hook("user-location-result", %{
        "lat" => 34.0522,
        "lng" => -118.2437
      })
      
      # This is mostly a smoke test to ensure the handler doesn't crash
      assert view
    end

    test "can cancel upload", %{conn: conn, user: user} do
      {:ok, view, _html} = 
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")
      
      # Simulate map click to open the create meetup modal
      view |> render_hook("location-selected", %{"lat" => 34.0522, "lng" => -118.2437})
      
      # Simulate file upload
      file_input = "test/support/fixtures/avatar.jpg"
      
      view
      |> file_input("#selected-position form input[type=file]", :avatar, [
        %{
          last_modified: 1_594_171_879_000,
          name: "avatar.jpg",
          content: File.read!(file_input),
          type: "image/jpeg"
        }
      ])
      
      # Cancel the upload
      view |> element("button[phx-click='cancel-upload']") |> render_click()
      
      # Verify the upload was cancelled
      refute has_element?(view, "figure figcaption", "avatar.jpg")
    end
  end
end
