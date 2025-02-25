defmodule LgbWeb.MeetupLive.Index do
  use LgbWeb, :live_view
  alias Lgb.Meetups

  def mount(_params, _session, socket) do
    meetups = Meetups.list_meetups()
    {:ok, assign(socket, meetups: meetups)}
  end

  def render(assigns) do
    ~H"""
    <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div class="flex justify-between items-center mb-6">
        <h1 class="text-3xl font-bold">Meetups</h1>
        <.link patch={~p"/meetups/new"} class="btn btn-primary">
          Create Meetup
        </.link>
      </div>

      <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        <%= for meetup <- @meetups do %>
          <div class="bg-white shadow rounded-lg p-6">
            <h2 class="text-xl font-semibold mb-2"><%= meetup.title %></h2>
            <p class="text-gray-600 mb-4"><%= meetup.description %></p>
            <div class="text-sm text-gray-500">
              <p>📍 <%= meetup.location_name %></p>
              <p>📅 <%= Calendar.strftime(meetup.date, "%B %d, %Y at %I:%M %p") %></p>
              <p>👥 <%= length(meetup.participants) %>/<%= meetup.max_participants %> participants</p>
            </div>
            <div class="mt-4">
              <.link patch={~p"/meetups/#{meetup.id}"} class="btn btn-secondary">
                View Details
              </.link>
            </div>
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
