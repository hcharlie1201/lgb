defmodule LgbWeb.MeetupLive.Components.EventCardComponent do
  use Phoenix.Component
  import LgbWeb.CoreComponents
  alias Phoenix.LiveView.JS

  use Phoenix.VerifiedRoutes,
    router: LgbWeb.Router,
    endpoint: LgbWeb.Endpoint

  attr :location, :map, required: true
  attr :profile, :any, required: true
  attr :map_id, :string

  def event_card(assigns) do
    ~H"""
    <.card class="bg-white/95 absolute top-16 bottom-10 left-10 z-10 w-1/6 overflow-hidden">
      <.header>Going events</.header>
      <div id="location-markers" class="max-h-96 space-y-4 overflow-y-auto" phx-update="stream">
        <div id="events-empty-state" class="hidden py-8 text-center italic text-gray-500 only:block">
          No meetups created yet. Click on the map to create one!
        </div>
        <div
          :for={{dom_id, location} <- @locations}
          id={dom_id}
          data-location={Jason.encode!(location)}
          class="cursor-pointer rounded-md bg-gray-100 p-4 hover:bg-gray-200"
          phx-click={
            JS.push_focus()
            |> JS.dispatch("focus-map-marker",
              detail: %{id: location.id, lat: location.latitude, lng: location.longitude}
            )
          }
        >
          <div :if={location.creator_id == @profile.id} class="flex justify-between">
            <.link class="link-style" navigate={~p"/meetups/#{location.uuid}"}>
              {location.location_name}
            </.link>
            <button
              phx-click="delete-location"
              phx-value-id={location.id}
              phx-value-dom_id={dom_id}
              class="text-red-500"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-5 w-5"
                viewBox="0 0 20 20"
                fill="currentColor"
              >
                <path
                  fill-rule="evenodd"
                  d="M9 2a1 1 0 00-.894.553L7.382 4H4a1 1 0 000 2v10a2 2 0 002 2h8a2 2 0 002-2V6a1 1 0 100-2h-3.382l-.724-1.447A1 1 0 0011 2H9zM7 8a1 1 0 012 0v6a1 1 0 11-2 0V8zm5-1a1 1 0 00-1 1v6a1 1 0 102 0V8a1 1 0 00-1-1z"
                  clip-rule="evenodd"
                />
              </svg>
            </button>
          </div>
          <p class="text-sm">{location.description}</p>
          <p class="mt-2 text-sm font-medium">
            <%= if location.date do %>
              {Calendar.strftime(location.date, "%B %d, %Y at %I:%M %p")}
            <% else %>
              No date specified
            <% end %>
          </p>
        </div>
      </div>
    </.card>
    """
  end
end
