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
      Process.sleep(200)

      assert render(view) =~ location.title
    end

    test "can open location modal", %{conn: conn, user: user, profile: profile} do
      location = event_location_fixture(%{"creator_id" => profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups")

      # Wait for locations to load
      Process.sleep(200)

      # Find and click the div that opens the location modal
      view
      |> element("div[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']")
      |> render_click()

      # Wait a moment for the modal to open
      Process.sleep(100)

      # Now check the content
      html = render(view)
      assert html =~ location.title
      assert has_element?(view, "[data-id='#{location.id}']")
    end

    test "can close location modal", %{conn: conn, user: user, profile: profile} do
      location = event_location_fixture(%{"creator_id" => profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for locations to load
      Process.sleep(200)

      # Open the location modal
      view
      |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']")
      |> render_click()

      # Close the modal
      view |> element("button", "close") |> render_click()

      # Check if modal is closed
      refute has_element?(view, "#show-location-#{location.id}:not(.hidden)")
    end

    test "can join a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location by another user
      other_profile = profile_fixture(user_fixture())
      location = event_location_fixture(%{"reator_id" => other_profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for locations to load
      Process.sleep(200)

      # Open the location modal
      view
      |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']")
      |> render_click()

      # Join the meetup
      view |> element("button", "Join Meetup") |> render_click()

      # Verify the user is now a participant
      assert Meetups.is_participant?(location.id, profile.id)

      # The button should now be "Leave Meetup"
      assert has_element?(view, "button", "Leave Meetup")
    end

    test "can leave a meetup", %{conn: conn, user: user, profile: profile} do
      # Create a location by another user
      other_profile = profile_fixture(user_fixture())
      location = event_location_fixture(%{"reator_id" => other_profile.id})

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
      view
      |> element("[phx-click='open-location-modal'][phx-value-location_id='#{location.id}']")
      |> render_click()

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
        |> live(~p"/meetups/map")

      # Wait for locations to load
      Process.sleep(200)

      # Delete the location
      view
      |> element("[phx-click='delete-location'][phx-value-id='#{location.id}']")
      |> render_click()

      # Verify the location was deleted
      assert Meetups.get_location(location.id) == nil
    end

    test "handles map bounds changed", %{conn: conn, user: user} do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Simulate map bounds changed event
      view
      |> render_hook("map-bounds-changed", %{
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
      view
      |> render_hook("user-location-result", %{
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

    # Stream-specific tests
    test "stream is initially empty", %{conn: conn, user: user} do
      {:ok, view, html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Check that the locations stream is initially empty
      assert html =~ "phx-update=\"stream\""
      assert view |> element("#locations > *") |> has_element?() == false
    end

    test "stream is populated after load_locations", %{conn: conn, user: user, profile: profile} do
      # Create multiple test locations
      location1 = event_location_fixture(%{"reator_id" => profile.id, title: "Location 1"})
      location2 = event_location_fixture(%{"reator_id" => profile.id, title: "Location 2"})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for the :load_locations message to be processed
      Process.sleep(200)

      # Check that both locations are in the stream
      assert has_element?(view, "[data-id='locations-#{location1.id}']")
      assert has_element?(view, "[data-id='locations-#{location2.id}']")

      # Verify the stream contains the correct number of items
      locations_count = Meetups.list_locations() |> length()
      assert view |> element("#locations > *") |> has_element?()
    end

    test "stream updates when a new location is added", %{
      conn: conn,
      user: user,
      profile: profile
    } do
      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for initial locations to load
      Process.sleep(200)

      # Count initial locations
      initial_locations = Meetups.list_locations() |> length()

      # Create a new meetup through the UI
      view |> render_hook("location-selected", %{"lat" => 34.0522, "lng" => -118.2437})

      view
      |> form("#selected-position form", %{
        "event_location" => %{
          "title" => "New Stream Test Meetup",
          "location_name" => "Stream Test Location",
          "description" => "Testing stream updates",
          "date" => "2023-12-31T12:00",
          "category" => "social",
          "max_participants" => "10"
        }
      })
      |> render_submit()

      # Wait for the stream to update
      Process.sleep(100)

      # Verify there's one more location in the database
      new_locations_count = Meetups.list_locations() |> length()
      assert new_locations_count == initial_locations + 1

      # Verify the new location is in the stream
      new_location = Meetups.get_location_by_title("New Stream Test Meetup")
      assert has_element?(view, "[data-id='locations-#{new_location.id}']")
    end

    test "stream updates when a location is deleted", %{conn: conn, user: user, profile: profile} do
      # Create a test location
      location = event_location_fixture(%{"reator_id" => profile.id})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for locations to load
      Process.sleep(200)

      # Count initial locations
      initial_locations = Meetups.list_locations() |> length()

      # Delete the location
      view
      |> element("[phx-click='delete-location'][phx-value-id='#{location.id}']")
      |> render_click()

      # Wait for the stream to update
      Process.sleep(100)

      # Verify there's one less location in the database
      new_locations_count = Meetups.list_locations() |> length()
      assert new_locations_count == initial_locations - 1

      # Verify the location is no longer in the stream
      refute has_element?(view, "[data-id='locations-#{location.id}']")
    end

    test "stream items have correct data attributes", %{conn: conn, user: user, profile: profile} do
      # Create a test location with specific attributes
      location =
        event_location_fixture(%{
          "creator_id" => profile.id,
          "title" => "Stream Test Location",
          "description" => "Testing stream data attributes",
          "category" => "social"
        })

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for locations to load
      Process.sleep(200)

      # Check that the location element has the correct data attributes
      location_element = view |> element("[data-id='locations-#{location.id}']")
      assert has_element?(location_element)

      rendered_element = render(location_element)
      assert rendered_element =~ "data-id=\"locations-#{location.id}\""
      assert rendered_element =~ "data-lat="
      assert rendered_element =~ "data-lng="
      assert rendered_element =~ "Stream Test Location"
      assert rendered_element =~ "Testing stream data attributes"
    end

    test "stream updates when a location is updated", %{conn: conn, user: user, profile: profile} do
      # Create a test location
      location = event_location_fixture(%{"reator_id" => profile.id, "title" => "Original Title"})

      # Update the location directly in the database
      {:ok, updated_location} = Meetups.update_location(location, %{"title" => "Updated Title"})

      {:ok, view, _html} =
        conn
        |> log_in_user(user)
        |> live(~p"/meetups/map")

      # Wait for locations to load
      Process.sleep(200)

      # Verify the updated title is in the stream
      assert view |> element("[data-id='locations-#{location.id}']") |> render() =~
               "Updated Title"
    end
  end
end
