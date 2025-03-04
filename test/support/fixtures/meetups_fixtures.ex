defmodule Lgb.MeetupsFixtures do
  @moduledoc """

  This module defines test helpers for creating

  entities via the `Lgb.Meetups` context.

  """

  @doc """

  Generate a event_location.

  """

  def event_location_fixture(attrs \\ %{}) do
    {:ok, event_location} =
      attrs
      |> Enum.into(%{
        "title" => "some title",
        "description" => "some description",
        "location_name" => "some location",
        "date" => DateTime.utc_now() |> DateTime.add(7, :day),
        "geolocation" => %Geo.Point{coordinates: {-122.27652, 37.80574}, srid: 4326},
        "category" => "outdoors_activities",
        "max_participants" => 10,
        "creator_id" => attrs["creator_id"]
      })
      |> Lgb.Meetups.create_location()

    event_location
  end
end
