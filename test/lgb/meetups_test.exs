defmodule Lgb.MeetupsTest do
  use Lgb.DataCase

  alias Lgb.Meetups
  alias Lgb.Meetups.{EventLocation, EventParticipant, EventComment, EventCommentReply}
  alias Lgb.Profiles.Profile

  describe "locations" do
    @valid_attrs %{
      description: "some description",
      title: "some title",
      date: ~N[2023-01-01 10:00:00],
      location_name: "some location",
      geolocation: %Geo.Point{coordinates: {-122.4194, 37.7749}, srid: 4326},
      max_participants: 10,
      category: "social"
    }
    @update_attrs %{
      description: "updated description",
      title: "updated title",
      max_participants: 20
    }
    @invalid_attrs %{description: nil, title: nil, geolocation: nil}

    def profile_fixture do
      {:ok, profile} =
        Lgb.Profiles.create_profile(%{
          handle: "test_user_#{System.unique_integer([:positive])}",
          age: 25,
          city: "Test City",
          state: "TS",
          user_id: Ecto.UUID.generate()
        })

      profile
    end

    def location_fixture(attrs \\ %{}) do
      profile = profile_fixture()

      {:ok, location} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Map.put(:creator_id, profile.id)
        |> Meetups.create_location()

      location
    end

    test "list_locations/0 returns all locations" do
      location = location_fixture()
      assert Enum.map(Meetups.list_locations(), & &1.id) |> Enum.member?(location.id)
    end

    test "get_location!/1 returns the location with given id" do
      location = location_fixture()
      fetched_location = Meetups.get_location!(location.id)
      assert fetched_location.id == location.id
      assert fetched_location.latitude == 37.7749
      assert fetched_location.longitude == -122.4194
    end

    test "create_location/1 with valid data creates a location" do
      profile = profile_fixture()
      valid_attrs = Map.put(@valid_attrs, :creator_id, profile.id)
      assert {:ok, %EventLocation{} = location} = Meetups.create_location(valid_attrs)
      assert location.description == "some description"
      assert location.title == "some title"
      assert location.max_participants == 10
    end

    test "create_location/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Meetups.create_location(@invalid_attrs)
    end

    test "update_location/2 with valid data updates the location" do
      location = location_fixture()
      assert {:ok, %EventLocation{} = location} = Meetups.update_location(location, @update_attrs)
      assert location.description == "updated description"
      assert location.title == "updated title"
      assert location.max_participants == 20
    end

    test "update_location/2 with invalid data returns error changeset" do
      location = location_fixture()
      assert {:error, %Ecto.Changeset{}} = Meetups.update_location(location, @invalid_attrs)
      assert location.id == Meetups.get_location!(location.id).id
    end

    test "delete_location/1 deletes the location" do
      location = location_fixture()
      assert {:ok, %EventLocation{}} = Meetups.delete_location(location)
      assert_raise Ecto.NoResultsError, fn -> Meetups.get_location!(location.id) end
    end

    test "change_location/1 returns a location changeset" do
      location = location_fixture()
      assert %Ecto.Changeset{} = Meetups.change_location(location)
    end

    test "locations_in_bounds/4 returns locations within the given bounds" do
      location = location_fixture()
      # Bounds that include San Francisco
      sw_lat = 37.70
      sw_lng = -122.50
      ne_lat = 37.80
      ne_lng = -122.40
      
      locations = Meetups.locations_in_bounds(sw_lat, sw_lng, ne_lat, ne_lng)
      assert Enum.any?(locations, fn loc -> loc.id == location.id end)
      
      # Bounds that don't include San Francisco
      sw_lat = 34.00
      sw_lng = -118.50
      ne_lat = 34.10
      ne_lng = -118.40
      
      locations = Meetups.locations_in_bounds(sw_lat, sw_lng, ne_lat, ne_lng)
      refute Enum.any?(locations, fn loc -> loc.id == location.id end)
    end

    test "list_locations_nearby/3 returns locations within the given distance" do
      location = location_fixture()
      # Coordinates close to San Francisco
      lat = 37.7749
      lng = -122.4194
      distance = 1000 # 1km
      
      locations = Meetups.list_locations_nearby(lat, lng, distance)
      assert Enum.any?(locations, fn loc -> loc.id == location.id end)
      
      # Coordinates far from San Francisco
      lat = 34.0522
      lng = -118.2437
      distance = 1000 # 1km
      
      locations = Meetups.list_locations_nearby(lat, lng, distance)
      refute Enum.any?(locations, fn loc -> loc.id == location.id end)
    end
  end

  describe "participants" do
    setup do
      profile = %Profile{
        id: Ecto.UUID.generate(),
        handle: "test_user",
        age: 25,
        city: "Test City",
        state: "TS"
      } |> Lgb.Repo.insert!()

      location = %EventLocation{
        description: "test event",
        title: "Test Event",
        date: ~N[2023-01-01 10:00:00],
        location_name: "Test Location",
        geolocation: %Geo.Point{coordinates: {-122.4194, 37.7749}, srid: 4326},
        max_participants: 2,
        creator_id: profile.id,
        uuid: Ecto.UUID.generate()
      } |> Lgb.Repo.insert!()

      %{profile: profile, location: location}
    end

    test "join_meetup/2 adds a user to a meetup", %{profile: profile, location: location} do
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      assert Meetups.is_participant?(location.id, profile.id)
    end

    test "join_meetup/2 prevents joining twice", %{profile: profile, location: location} do
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      assert {:error, :already_participating} = Meetups.join_meetup(location.id, profile.id)
    end

    test "join_meetup/2 prevents joining when event is full", %{profile: profile, location: location} do
      # Create another profile
      profile2 = %Profile{
        id: Ecto.UUID.generate(),
        handle: "test_user2",
        age: 26,
        city: "Test City",
        state: "TS"
      } |> Lgb.Repo.insert!()

      profile3 = %Profile{
        id: Ecto.UUID.generate(),
        handle: "test_user3",
        age: 27,
        city: "Test City",
        state: "TS"
      } |> Lgb.Repo.insert!()

      # Join with first two profiles (max is 2)
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile2.id)
      
      # Third profile should be rejected
      assert {:error, :event_full} = Meetups.join_meetup(location.id, profile3.id)
    end

    test "leave_meetup/2 removes a user from a meetup", %{profile: profile, location: location} do
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      assert {:ok, %EventParticipant{}} = Meetups.leave_meetup(location.id, profile.id)
      refute Meetups.is_participant?(location.id, profile.id)
    end

    test "leave_meetup/2 returns error when not participating", %{profile: profile, location: location} do
      assert {:error, :not_participating} = Meetups.leave_meetup(location.id, profile.id)
    end

    test "count_participants/1 returns the correct count", %{profile: profile, location: location} do
      assert Meetups.count_participants(location.id) == 0
      
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      assert Meetups.count_participants(location.id) == 1
      
      profile2 = %Profile{
        id: Ecto.UUID.generate(),
        handle: "test_user2",
        age: 26,
        city: "Test City",
        state: "TS"
      } |> Lgb.Repo.insert!()
      
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile2.id)
      assert Meetups.count_participants(location.id) == 2
    end

    test "list_participants/1 returns all participants", %{profile: profile, location: location} do
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      
      participants = Meetups.list_participants(location.id)
      assert length(participants) == 1
      assert Enum.at(participants, 0).id == profile.id
    end

    test "get_user_participation_status/2 returns correct status", %{profile: profile, location: location} do
      assert Meetups.get_user_participation_status(location, profile) == :not_attending
      
      assert {:ok, %EventParticipant{}} = Meetups.join_meetup(location.id, profile.id)
      assert Meetups.get_user_participation_status(location, profile) == :attending
      
      assert Meetups.get_user_participation_status(location, nil) == :not_attending
    end
  end

  describe "comments and replies" do
    setup do
      profile = %Profile{
        id: Ecto.UUID.generate(),
        handle: "test_user",
        age: 25,
        city: "Test City",
        state: "TS"
      } |> Lgb.Repo.insert!()

      location = %EventLocation{
        description: "test event",
        title: "Test Event",
        date: ~N[2023-01-01 10:00:00],
        location_name: "Test Location",
        geolocation: %Geo.Point{coordinates: {-122.4194, 37.7749}, srid: 4326},
        max_participants: 10,
        creator_id: profile.id,
        uuid: Ecto.UUID.generate()
      } |> Lgb.Repo.insert!()

      %{profile: profile, location: location}
    end

    test "create_event_comment/1 creates a comment", %{profile: profile, location: location} do
      attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }

      assert {:ok, %EventComment{} = comment} = Meetups.create_event_comment(attrs)
      assert comment.content == "Test comment"
      assert comment.profile_id == profile.id
      assert comment.event_location_id == location.id
    end

    test "list_event_comments/1 returns all comments for a location", %{profile: profile, location: location} do
      # Create a comment
      attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }
      {:ok, _comment} = Meetups.create_event_comment(attrs)

      comments = Meetups.list_event_comments(location)
      assert length(comments) == 1
      assert Enum.at(comments, 0).content == "Test comment"
    end

    test "toggle_comment_like/2 toggles a like on a comment", %{profile: profile, location: location} do
      # Create a comment
      attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }
      {:ok, comment} = Meetups.create_event_comment(attrs)

      # Like the comment
      assert {:ok, updated_comment} = Meetups.toggle_comment_like(comment.id, profile.id)
      assert updated_comment.likes_count == 1

      # Unlike the comment
      assert {:ok, updated_comment} = Meetups.toggle_comment_like(comment.id, profile.id)
      assert updated_comment.likes_count == 0
    end

    test "create_comment_reply/1 creates a reply", %{profile: profile, location: location} do
      # Create a comment
      comment_attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }
      {:ok, comment} = Meetups.create_event_comment(comment_attrs)

      # Create a reply
      reply_attrs = %{
        content: "Test reply",
        profile_id: profile.id,
        event_comment_id: comment.id
      }
      assert {:ok, %EventCommentReply{} = reply} = Meetups.create_comment_reply(reply_attrs)
      assert reply.content == "Test reply"
      assert reply.profile_id == profile.id
      assert reply.event_comment_id == comment.id
    end

    test "toggle_reply_like/2 toggles a like on a reply", %{profile: profile, location: location} do
      # Create a comment
      comment_attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }
      {:ok, comment} = Meetups.create_event_comment(comment_attrs)

      # Create a reply
      reply_attrs = %{
        content: "Test reply",
        profile_id: profile.id,
        event_comment_id: comment.id
      }
      {:ok, reply} = Meetups.create_comment_reply(reply_attrs)

      # Like the reply
      assert {:ok, updated_reply} = Meetups.toggle_reply_like(reply.id, profile.id)
      assert length(updated_reply.likes) == 1

      # Unlike the reply
      assert {:ok, updated_reply} = Meetups.toggle_reply_like(reply.id, profile.id)
      assert length(updated_reply.likes) == 0
    end

    test "delete_event_comment/2 deletes a comment", %{profile: profile, location: location} do
      # Create a comment
      attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }
      {:ok, comment} = Meetups.create_event_comment(attrs)

      # Delete the comment
      assert {:ok, %EventComment{}} = Meetups.delete_event_comment(comment.id, profile.id)
      
      # Verify it's deleted
      comments = Meetups.list_event_comments(location)
      assert length(comments) == 0
    end

    test "delete_comment_reply/2 deletes a reply", %{profile: profile, location: location} do
      # Create a comment
      comment_attrs = %{
        content: "Test comment",
        profile_id: profile.id,
        event_location_id: location.id
      }
      {:ok, comment} = Meetups.create_event_comment(comment_attrs)

      # Create a reply
      reply_attrs = %{
        content: "Test reply",
        profile_id: profile.id,
        event_comment_id: comment.id
      }
      {:ok, reply} = Meetups.create_comment_reply(reply_attrs)

      # Delete the reply
      assert {:ok, %EventCommentReply{}} = Meetups.delete_comment_reply(reply.id, profile.id)
      
      # Verify it's deleted by checking the comment has no replies
      {:ok, refreshed_comment} = Meetups.create_event_comment(comment_attrs)
      assert length(refreshed_comment.replies) == 0
    end
  end
end
