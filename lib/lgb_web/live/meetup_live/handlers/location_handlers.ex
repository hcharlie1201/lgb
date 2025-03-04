defmodule LgbWeb.MeetupLive.Handlers.LocationHandlers do
  @moduledoc """
  Handlers for location management in the Meetup LiveView.
  """
  import Phoenix.LiveView
  import Phoenix.Component
  alias Lgb.Meetups
  alias Lgb.Meetups.EventLocation

  @doc """
  Opens the location detail modal.
  """
  def open_location_modal(location_id, socket) do
    # Get the full location details
    location = Meetups.get_location!(location_id)
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    is_participant = Meetups.is_participant?(location_id, current_profile.id)
    is_creator = location.creator_id == current_profile.id
    {lng, lat} = location.geolocation.coordinates

    # Create a map with all the data needed for display
    location_for_modal = %{
      id: location.id,
      uuid: location.uuid,
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
      participant_count: Meetups.count_participants(location_id)
    }

    {:noreply,
     socket
     |> assign(:selected_location, location_for_modal)
     |> assign(:show_location_modal, true)}
  end

  @doc """
  Closes the location detail modal.
  """
  def close_location_modal(socket) do
    {:noreply,
     socket
     |> assign(:selected_location, nil)
     |> assign(:show_location_modal, false)}
  end

  def close_position_modal(socket) do
    {:noreply,
     socket
     |> assign(:show_selected_position_modal, false)}
  end

  @doc """
  Handles deleting a location.
  """
  def handle_delete_location(id, dom_id, socket) do
    id = String.to_integer(id)
    location = Meetups.get_location!(id)
    {:ok, _} = Meetups.delete_location(location)

    # Delete from the stream by ID
    {:noreply,
     socket
     |> stream_delete_by_dom_id(:locations, dom_id)
     |> put_flash(:info, "Meetup location deleted")}
  end

  @doc """
  Saves a new location based on the form data and selected position.
  """
  def save_location(socket, location_params) do
    case socket.assigns.selected_position do
      nil ->
        {:noreply, put_flash(socket, :error, "Please select a location on the map first.")}

      position ->
        do_save_location(socket, location_params, position)
    end
  end

  @doc """
  Loads all locations and formats them for display.
  """
  def load_locations(socket) do
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

    # Reset the stream with all locations
    {:noreply, socket |> stream(:locations, formatted_locations, reset: true)}
  end

  # Private functions

  defp do_save_location(socket, location_params, position) do
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    updated_params =
      Map.merge(location_params, %{
        "geolocation" => %Geo.Point{
          coordinates: {String.to_float(position.longitude), String.to_float(position.latitude)},
          srid: 4326
        },
        "creator_id" => profile.id
      })

    case uploaded_entries(socket, :avatar) do
      {[], []} ->
        handle_location_creation(socket, updated_params, profile)

      _ ->
        consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
          handle_location_creation(socket, updated_params, profile, %{entry: entry, path: path})
        end)
        |> Enum.at(0)
    end
  end

  defp handle_location_creation(socket, location_params, profile, metadata \\ nil) do
    case Meetups.create_location(location_params, metadata) do
      {:ok, location} ->
        formatted_location =
          Meetups.normalize_location([location])
          |> List.first()
          |> Map.merge(%{
            is_participant: false,
            is_creator: location.creator_id == profile.id
          })

        {:noreply,
         socket
         |> stream_insert(:locations, formatted_location)
         |> assign(:selected_position, nil)
         |> assign(:show_selected_position_modal, false)
         |> assign(:form, to_form(Meetups.change_location(%EventLocation{})))
         |> put_flash(:info, "Meetup location created successfully")}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(:error, "Error creating meetup location")}
    end
  end
end
