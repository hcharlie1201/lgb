defmodule LgbWeb.MeetupLive.Map do
  use LgbWeb, :live_view
  alias Lgb.Meetups
  alias Lgb.Meetups.EventLocation

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :load_locations, 100)

    {:ok,
     socket
     |> assign(:locations, [])
     |> assign(:form, to_form(Meetups.change_location(%EventLocation{})))
     |> assign(:map_id, "meetup-map-#{socket.assigns.current_user.uuid}")
     |> assign(:selected_position, nil)
     |> assign(:show_location_modal, false)
     |> assign(:selected_location, nil)}
  end

  @impl true
  def handle_event("validate", %{"event_location" => location_params}, socket) do
    changeset =
      %EventLocation{}
      |> Meetups.change_location(location_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("location-selected", %{"lat" => lat, "lng" => lng}, socket) do
    {:noreply,
     socket
     |> assign(:selected_position, %{latitude: lat, longitude: lng})
     |> put_flash(:info, "Location selected. Fill out the form to create a meetup.")}
  end

  @impl true
  def handle_event("map-bounds-changed", %{"bounds" => bounds}, socket) do
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

  @impl true
  def handle_event("save-location", %{"event_location" => location_params}, socket) do
    case socket.assigns.selected_position do
      nil ->
        {:noreply, put_flash(socket, :error, "Please select a location on the map first.")}

      position ->
        save_location(socket, location_params, position)
    end
  end

  @doc """
  Event from Hook
  """
  @impl true
  def handle_event("open-location-modal", %{"location_id" => location_id}, socket) do
    # Get the full location details
    location = Meetups.get_location!(location_id)
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    is_participant = Meetups.is_participant?(location_id, current_profile.id)
    is_creator = location.creator_id == current_profile.id
    {lng, lat} = location.geolocation.coordinates

    # Create a map with all the data needed for display
    location_for_modal = %{
      id: location.id,
      title: location.title,
      description: location.description,
      location_name: location.location_name,
      category: location.category,
      date: location.date,
      max_participants: location.max_participants,
      latitude: lat,
      longitude: lng,
      is_participant: is_participant,
      is_creator: is_creator,
      creator_id: location.creator_id,
      # Add participant count if you have that data available
      participant_count: Meetups.count_participants(location_id)
    }

    {:noreply,
     socket
     |> assign(:selected_location, location_for_modal)
     |> assign(:show_location_modal, true)}
  end

  # You'll also need a handler to close the modal
  @impl true
  def handle_event("close-location-modal", _params, socket) do
    {:noreply,
     socket
     |> assign(:selected_location, nil)
     |> assign(:show_location_modal, false)}
  end

  @impl true
  def handle_event("join-meetup", %{"id" => location_id}, socket) do
    # Get the current user's profile
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    location_id = String.to_integer(location_id)

    # Join the meetup
    case Meetups.join_meetup(location_id, current_profile.id) do
      {:ok, _participant} ->
        # Refresh the locations data after successful join
        Process.send_after(self(), :load_locations, 100)

        {:noreply,
         socket
         |> assign(:show_location_modal, false)
         |> put_flash(:info, "You've successfully joined this meetup!")}

      {:error, :already_participating} ->
        {:noreply,
         socket
         |> put_flash(:info, "You're already participating in this meetup.")}

      {:error, :event_full} ->
        {:noreply,
         socket
         |> put_flash(:error, "This meetup is already at maximum capacity.")}

      {:error, _changeset} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error joining the meetup. Please try again.")}
    end
  end

  @impl true
  def handle_event("leave-meetup", %{"id" => location_id}, socket) do
    # Get the current user's profile
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    location_id = String.to_integer(location_id)

    # Leave the meetup
    case Meetups.leave_meetup(location_id, current_profile.id) do
      {:ok, _} ->
        # Refresh the locations data after successful leave
        Process.send_after(self(), :load_locations, 100)

        {:noreply,
         socket
         |> assign(:show_location_modal, false)
         |> put_flash(:info, "You've left this meetup.")}

      {:error, :not_participating} ->
        {:noreply,
         socket
         |> put_flash(:info, "You're not participating in this meetup.")}

      {:error, _} ->
        {:noreply,
         socket
         |> put_flash(:error, "Error leaving the meetup. Please try again.")}
    end
  end

  @impl true
  def handle_event("delete-location", %{"id" => id}, socket) do
    location = Meetups.get_location!(id)
    {:ok, _} = Meetups.delete_location(location)

    {:noreply,
     socket
     |> assign(:locations, Meetups.list_locations())
     |> put_flash(:info, "Meetup location deleted")}
  end

  @impl true
  def handle_event("find-nearby", %{"radius" => radius}, socket) do
    # Get current user location from browser
    {:noreply, push_event(socket, "get-user-location", %{radius: radius})}
  end

  @impl true
  def handle_event(
        "user-location-result",
        %{"lat" => lat, "lng" => lng, "radius" => radius},
        socket
      ) do
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

  @impl true
  def handle_info(:load_locations, socket) do
    # Get the current user's profile
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    # Get all locations
    locations = Meetups.list_locations()

    # Format for the UI with participation info
    formatted_locations =
      locations
      |> Meetups.normalize_location()
      |> Enum.map(fn location ->
        # Check if current user is participating
        is_participant = Meetups.is_participant?(location.id, current_profile.id)

        # Check if current user is the creator
        is_creator = location.creator_id == current_profile.id

        # Create a map with the needed fields
        Map.merge(location, %{
          is_participant: is_participant,
          is_creator: is_creator
        })
      end)

    {:noreply,
     socket
     |> assign(:locations, formatted_locations)
     |> push_event("update-locations", %{locations: formatted_locations})}
  end

  defp save_location(socket, location_params, position) do
    # Add the position and user_id to the params
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    location_params =
      Map.merge(location_params, %{
        "geolocation" => %Geo.Point{
          coordinates: {String.to_float(position.longitude), String.to_float(position.latitude)},
          srid: 4326
        },
        "creator_id" => profile.id
      })

    case Meetups.create_location(location_params) do
      {:ok, _location} ->
        # Reload all locations to get the formatted data
        locations = Meetups.list_locations()
        formatted_locations = Meetups.normalize_location(locations)

        {:noreply,
         socket
         |> assign(:locations, formatted_locations)
         |> assign(:selected_position, nil)
         |> assign(:form, to_form(Meetups.change_location(%EventLocation{})))
         |> push_event("update-locations", %{locations: formatted_locations})
         |> put_flash(:info, "Meetup location created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset)

        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, "Error creating meetup location")}
    end
  end

  @impl true
  def handle_info({LgbWeb.Presence, {:join, _presence}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({LgbWeb.Presence, {:leave, _presence}}, socket) do
    {:noreply, socket}
  end
end
