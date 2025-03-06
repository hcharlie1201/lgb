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
    <.card class="z-2 absolute top-16 bottom-10 left-10 flex w-1/5 flex-col bg-white">
      <.header class="mb-4">Going events</.header>
      <div
        id="location-markers"
        phx-update="stream"
        class="max-h-[calc(100%-4rem)] no-scrollbar flex-1 overflow-y-auto"
      >
        <div id="events-empty-state" class="hidden py-8 text-center italic text-gray-500 only:block">
          No meetups created yet. Click on the map to create one!
        </div>
        <div
          :for={{dom_id, location} <- @locations}
          id={dom_id}
          data-location={Jason.encode!(location)}
          class="mb-4 cursor-pointer"
          phx-click={
            JS.push_focus()
            |> JS.dispatch("focus-map-marker",
              detail: %{id: location.id, lat: location.latitude, lng: location.longitude}
            )
          }
        >
          <div :if={location.creator_id == @profile.id} class="px-4">
            <img class="w-full rounded-2xl" src={location.url} />
            <div class="mt-2 mb-6 flex justify-between">
              <section>
                <.link class="link-style text-xl" navigate={~p"/meetups/#{location.uuid}"}>
                  {location.location_name}
                </.link>
                <p class="text-sm font-light text-gray-500">{location.description}</p>
                <p class="text-sm font-light text-gray-500">
                  <%= if location.date do %>
                    {Calendar.strftime(location.date, "%B %d, %Y at %I:%M %p")}
                  <% else %>
                    No date specified
                  <% end %>
                </p>
              </section>
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
          </div>
        </div>
      </div>
    </.card>
    """
  end
end
