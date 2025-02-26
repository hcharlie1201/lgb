defmodule LgbWeb.MeetupLive.Handlers.MapHandlers do
  @moduledoc """
  Handlers for map-related interactions in the Meetup LiveView.
  """
  import Phoenix.LiveView
  import Phoenix.Component
  alias Lgb.Meetups

  @doc """
  Handles when a user clicks on the map to select a location.
  """
  def handle_location_selected(%{"lat" => lat, "lng" => lng}, socket) do
    {:noreply,
     socket
     |> assign(:selected_position, %{latitude: lat, longitude: lng})
     |> put_flash(:info, "Location selected. Fill out the form to create a meetup.")}
  end

  @doc """
  Handles when the map bounds change, fetching locations within the visible area.
  """
  def handle_map_bounds_changed(%{"bounds" => bounds}, socket) do
    %{"sw_lat" => sw_lat, "sw_lng" => sw_lng, "ne_lat" => ne_lat, "ne_lng" => ne_lng} = bounds

    # Get locations within the current map bounds
    locations =
      Meetups.locations_in_bounds(
        String.to_float(sw_lat),
        String.to_float(sw_lng),
        String.to_float(ne_lat),
        String.to_float(ne_lng)
      )

    # Push locations to the map hook
    {:noreply, push_event(socket, "update-locations", %{locations: locations})}
  end

  @doc """
  Handles the "find nearby" button click, requesting user location.
  """
  def handle_find_nearby(%{"radius" => radius}, socket) do
    # Get current user location from browser
    {:noreply, push_event(socket, "get-user-location", %{radius: radius})}
  end

  @doc """
  Processes user location data and finds nearby meetups.
  """
  def handle_user_location_result(%{"lat" => lat, "lng" => lng, "radius" => radius}, socket) do
    # Find locations near the user
    nearby_locations =
      Meetups.list_locations_nearby(
        String.to_float(lat),
        String.to_float(lng),
        String.to_float(radius)
      )

    # Format for the UI
    locations = Lgb.Meetups.normalize_location(nearby_locations)

    {:noreply,
     socket
     |> assign(:locations, locations)
     |> push_event("update-locations", %{locations: locations})
     |> push_event("center-map", %{lat: lat, lng: lng, zoom: 13})}
  end
end
