defmodule Lgb.Meetups do
  import Ecto.Query
  import Geo.PostGIS
  alias Lgb.Repo
  alias Lgb.Meetups.EventLocation

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
    Repo.all(
      from p in Lgb.Meetups.EventParticipant,
        where: p.event_location_id == ^event_location_id,
        preload: [:profile]
    )
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
    location = Repo.get!(EventLocation, id)

    # Extract coordinates from PostGIS point
    %{coordinates: {lng, lat}} = location.geolocation

    # Add latitude and longitude for the UI
    Map.merge(location, %{latitude: lat, longitude: lng})
  end

  def create_location(attrs \\ %{}) do
    %EventLocation{}
    |> EventLocation.changeset(attrs)
    |> Repo.insert()
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
        date: location.date,
        description: location.description,
        title: location.title,
        category: location.category,
        latitude: lat,
        longitude: lng,
        location_name: location.location_name,
        max_participants: location.max_participants,
        creator_id: location.creator_id
      }
    end)
  end
end
