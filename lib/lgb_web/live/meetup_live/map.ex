defmodule LgbWeb.MeetupLive.Map do
  use LgbWeb, :live_view
  alias Lgb.Meetups
  alias Lgb.Meetups.EventLocation
  alias LgbWeb.MeetupLive.Handlers.{MapHandlers, LocationHandlers, ParticipantHandlers}

  #
  # Lifecycle callbacks
  #
  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket), do: Process.send_after(self(), :load_locations, 100)

    {:ok,
     socket
     |> stream(:locations, [])
     |> assign(:form, to_form(Meetups.change_location(%EventLocation{})))
     |> assign(:map_id, "meetup-map-#{socket.assigns.current_user.uuid}")
     |> assign(:selected_position, nil)
     |> assign(:show_selected_position_modal, false)
     |> assign(:show_location_modal, false)
     |> assign(:selected_location, nil)
     |> assign(:profile, Lgb.Accounts.User.current_profile(socket.assigns.current_user))}
  end

  #
  # Form event handlers
  #
  @impl true
  def handle_event("validate", %{"event_location" => location_params}, socket) do
    changeset =
      %EventLocation{}
      |> Meetups.change_location(location_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, form: to_form(changeset))}
  end

  @impl true
  def handle_event("save-location", %{"event_location" => location_params}, socket) do
    LocationHandlers.save_location(socket, location_params)
  end

  #
  # Map interaction event handlers
  #
  @impl true
  def handle_event("location-selected", params, socket) do
    MapHandlers.handle_location_selected(params, socket)
  end

  @impl true
  def handle_event("map-bounds-changed", params, socket) do
    MapHandlers.handle_map_bounds_changed(params, socket)
  end

  @impl true
  def handle_event("find-nearby", params, socket) do
    MapHandlers.handle_find_nearby(params, socket)
  end

  @impl true
  def handle_event("user-location-result", params, socket) do
    MapHandlers.handle_user_location_result(params, socket)
  end

  #
  # Modal/UI event handlers
  #
  @impl true
  def handle_event("open-location-modal", %{"location_id" => location_id}, socket) do
    LocationHandlers.open_location_modal(location_id, socket)
  end

  @impl true
  def handle_event("close-location-modal", _params, socket) do
    LocationHandlers.close_location_modal(socket)
  end

  @impl true
  def handle_event("close-position-modal", _params, socket) do
    LocationHandlers.close_position_modal(socket)
  end

  #
  # Participant management event handlers
  #
  @impl true
  def handle_event("join-meetup", %{"id" => location_id}, socket) do
    ParticipantHandlers.handle_join_meetup(location_id, socket)
  end

  @impl true
  def handle_event("leave-meetup", %{"id" => location_id}, socket) do
    ParticipantHandlers.handle_leave_meetup(location_id, socket)
  end

  #
  # Location management event handlers
  #
  @impl true
  def handle_event("delete-location", %{"id" => id}, socket) do
    LocationHandlers.handle_delete_location(id, socket)
  end

  #
  # Other LiveView callbacks
  #
  @impl true
  def handle_info(:load_locations, socket) do
    LocationHandlers.load_locations(socket)
  end

  @impl true
  def handle_info({LgbWeb.Presence, {:join, presence}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({LgbWeb.Presence, {:leave, presence}}, socket) do
    {:noreply, socket}
  end
end
