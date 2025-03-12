defmodule Lgb.Meetups do
  import Ecto.Query
  import Geo.PostGIS
  alias Lgb.Repo

  alias Lgb.Meetups.{
    EventLocation,
    EventParticipant,
    EventComment,
    CommentLike,
    EventCommentReply,
    CommentReplyLike
  }

  @doc """
  Joins a user to a meetup event.
  """
  def join_meetup(event_location_id, profile_id) do
    # Get the location
    location = get_location!(event_location_id)

    # Check if the user is already participating
    if is_participant?(event_location_id, profile_id) do
      {:error, :already_participating}
    else
      # Check if there's a maximum participant limit and if it's reached
      if location.max_participants &&
           count_participants(event_location_id) >= location.max_participants do
        {:error, :event_full}
      else
        # Create the participation record
        %Lgb.Meetups.EventParticipant{}
        |> Ecto.Changeset.change(%{
          profile_id: profile_id,
          event_location_id: event_location_id
        })
        |> Repo.insert()
      end
    end
  end

  @doc """
  Removes a user from a meetup event.
  """
  def leave_meetup(event_location_id, profile_id) do
    # Find the participation record
    Lgb.Meetups.EventParticipant
    |> Repo.get_by(event_location_id: event_location_id, profile_id: profile_id)
    |> case do
      nil -> {:error, :not_participating}
      participant -> Repo.delete(participant)
    end
  end

  @doc """
  Checks if a user is participating in a meetup.
  """
  def is_participant?(event_location_id, profile_id) do
    Repo.exists?(
      from p in Lgb.Meetups.EventParticipant,
        where: p.event_location_id == ^event_location_id and p.profile_id == ^profile_id
    )
  end

  @doc """
  Counts the number of participants for a meetup.
  """
  def count_participants(event_location_id) do
    Repo.one(
      from p in Lgb.Meetups.EventParticipant,
        where: p.event_location_id == ^event_location_id,
        select: count(p.id)
    )
  end

  @doc """
  Lists all participants for a meetup.
  """
  def list_participants(event_location_id) do
    Lgb.Meetups.get_location!(event_location_id)
    |> Repo.preload(participants: :first_picture)
    |> Map.get(:participants)
  end

  @doc """
  Gets a location with participants preloaded.
  """
  def get_location_with_participants!(id) do
    Repo.get!(EventLocation, id)
    |> Repo.preload(participants: [:profile])
  end

  def list_locations do
    Repo.all(EventLocation)
  end

  # Find locations within a certain distance (in meters)
  def list_locations_nearby(lat, lng, distance_in_meters) do
    point = %Geo.Point{coordinates: {lng, lat}, srid: 4326}

    from(l in EventLocation,
      where: st_dwithin_in_meters(l.geolocation, ^point, ^distance_in_meters),
      order_by: st_distance_in_meters(l.geolocation, ^point)
    )
    |> Repo.all()
  end

  # Get location with its latitude and longitude for the UI
  def get_location!(id) do
    location = Repo.get(EventLocation, id)

    if location != nil do
      %{coordinates: {lng, lat}} = location.geolocation
      Map.merge(location, %{latitude: lat, longitude: lng})
    else
      location
    end
  end

  def get_location_by_uuid(uuid) do
    IO.inspect(uuid)
    location = Repo.get_by!(EventLocation, uuid: uuid)

    # Extract coordinates from PostGIS point
    %{coordinates: {lng, lat}} = location.geolocation

    # Add latitude and longitude for the UI
    Map.merge(location, %{latitude: lat, longitude: lng})
  end

  def get_host(event_location) do
    Repo.get!(Lgb.Profiles.Profile, event_location.creator_id)
    |> Repo.preload(:first_picture)
  end

  def create_location(attrs \\ %{}, image_upload \\ nil) do
    uuid = Ecto.UUID.generate()
    attrs = Lgb.Uploader.maybe_add_image(attrs, image_upload) |> Map.put("uuid", uuid)

    result =
      %EventLocation{}
      |> EventLocation.changeset(attrs)
      |> Repo.insert()

    # Clean up temp file if it exists
    if image_upload do
      Lgb.Uploader.cleanup_temp_file(image_upload.entry)
    end

    result
  end

  def update_location(%EventLocation{} = location, attrs) do
    location
    |> EventLocation.changeset(attrs)
    |> Repo.update()
  end

  def delete_location(%EventLocation{} = location) do
    Repo.delete(location)
  end

  def change_location(%EventLocation{} = location, attrs \\ %{}) do
    EventLocation.changeset(location, attrs)
  end

  # Find locations within bounding box (for map viewport)
  def locations_in_bounds(sw_lat, sw_lng, ne_lat, ne_lng) do
    # Create a polygon from the bounds
    polygon = %Geo.Polygon{
      coordinates: [
        [
          {sw_lng, sw_lat},
          {sw_lng, ne_lat},
          {ne_lng, ne_lat},
          {ne_lng, sw_lat},
          {sw_lng, sw_lat}
        ]
      ],
      srid: 4326
    }

    query =
      from l in EventLocation,
        where: st_within(l.geolocation, ^polygon)

    Repo.all(query) |> normalize_location()
  end

  # For the UI
  def normalize_location(locations) do
    Enum.map(locations, fn location ->
      %{coordinates: {lng, lat}} = location.geolocation

      %{
        id: location.id,
        uuid: location.uuid,
        date: location.date,
        description: location.description,
        title: location.title,
        category: location.category,
        latitude: lat,
        longitude: lng,
        location_name: location.location_name,
        max_participants: location.max_participants,
        creator_id: location.creator_id,
        url:
          if location.image do
            Lgb.Meetups.EventLocationPictureUplodaer.url(
              {location.image, location},
              :original,
              signed: true
            )
          else
            nil
          end
      }
    end)
  end

  def delete_event_comment(comment_id, profile_id) do
    comment = Repo.get!(EventComment, comment_id)

    # Optional: Add authorization check
    if comment.profile_id != profile_id do
      {:error, "You can only delete your own comments"}
    else
      Repo.delete(comment)
    end
  end

  def delete_comment_reply(reply_id, profile_id) do
    reply = Repo.get!(EventCommentReply, reply_id)

    # Optional: Add authorization check
    if reply.profile_id != profile_id do
      {:error, "You can only delete your own replies"}
    else
      Repo.delete(reply)
    end
  end

  @doc """
  List all comments for an event location with replies and profiles.
  """
  def list_event_comments(event_location) do
    query =
      from c in EventComment,
        where: c.event_location_id == ^event_location.id,
        order_by: [desc: c.inserted_at],
        preload: [profile: :first_picture, replies: [:likes, profile: :first_picture]]

    Repo.all(query)
    |> Enum.map(fn comment ->
      likes_count =
        length(Repo.all(from l in CommentLike, where: l.event_comment_id == ^comment.id))

      Map.put(comment, :likes_count, likes_count)
    end)
  end

  @doc """
  Get the participation status of a user for an event.
  """
  def get_user_participation_status(event_location, profile) do
    if is_nil(profile) do
      :not_attending
    else
      if is_participant?(event_location.id, profile.id) do
        :attending
      else
        :not_attending
      end
    end
  end

  @doc """
  Join an event.
  """
  def join_event(event_location, user) do
    case join_meetup(event_location.id, user.profile.id) do
      {:ok, participant} ->
        participant = Repo.preload(participant, :profile)
        {:ok, participant}

      {:error, :already_participating} ->
        {:error, "You are already attending this event"}

      {:error, :event_full} ->
        {:error, "This event is full"}

      {:error, changeset} ->
        {:error, "Could not join: #{inspect(changeset.errors)}"}
    end
  end

  @doc """
  Leave an event.
  """
  def leave_event(event_location, user) do
    case leave_meetup(event_location.id, user.profile.id) do
      {:ok, record} -> {:ok, record}
      {:error, :not_participating} -> {:error, "You are not attending this event"}
      {:error, changeset} -> {:error, "Could not leave: #{inspect(changeset.errors)}"}
    end
  end

  @doc """
  Create a comment for an event.
  """
  def create_event_comment(attrs) do
    %EventComment{}
    |> EventComment.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, comment} ->
        {:ok, Lgb.Repo.preload(comment, [:replies, profile: :first_picture])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Toggle a like on a comment.
  """
  def toggle_comment_like(comment_id, profile_id) do
    # Check if like already exists
    like_query =
      from l in CommentLike,
        where: l.event_comment_id == ^comment_id and l.profile_id == ^profile_id

    existing_like = Repo.one(like_query)

    # Get the comment for returning later
    comment =
      Repo.get!(EventComment, comment_id)
      |> Repo.preload(profile: :first_picture, replies: [:likes, profile: :first_picture])

    result =
      if existing_like do
        # Unlike
        Repo.delete(existing_like)
      else
        # Like
        %CommentLike{}
        |> CommentLike.changeset(%{event_comment_id: comment_id, profile_id: profile_id})
        |> Repo.insert()
      end

    case result do
      {:ok, _} ->
        # Return updated comment with likes count
        likes_count =
          Repo.one(
            from l in CommentLike, where: l.event_comment_id == ^comment_id, select: count(l.id)
          )

        updated_comment = Map.put(comment, :likes_count, likes_count)
        {:ok, updated_comment}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Create a reply to a comment.
  """
  def create_comment_reply(attrs) do
    %EventCommentReply{}
    |> EventCommentReply.changeset(attrs)
    |> Repo.insert()
    |> case do
      {:ok, reply} ->
        {:ok, Repo.preload(reply, [:likes, profile: :first_picture])}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @doc """
  Toggle a like on a comment reply.
  """
  def toggle_reply_like(reply_id, profile_id) do
    # Check if like already exists using a query
    like_query =
      from l in CommentReplyLike,
        where: l.event_comment_reply_id == ^reply_id and l.profile_id == ^profile_id

    existing_like = Repo.one(like_query)

    # Toggle the like status
    result =
      if existing_like do
        # Unlike
        Repo.delete(existing_like)
      else
        # Like
        %CommentReplyLike{}
        |> CommentReplyLike.changeset(%{
          event_comment_reply_id: reply_id,
          profile_id: profile_id
        })
        |> Repo.insert()
      end

    # Return the updated reply with freshly loaded associations
    case result do
      {:ok, _} ->
        updated_reply =
          EventCommentReply
          |> Repo.get!(reply_id)
          |> Repo.preload([:likes, profile: :first_picture])

        {:ok, updated_reply}

      {:error, changeset} ->
        {:error, changeset}
    end
  end
end
