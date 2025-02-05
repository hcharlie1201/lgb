defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  alias Lgb.Profiles
  alias LgbWeb.Components.Carousel

  def render(assigns) do
    ~H"""
    <.page_align>
      <.card>
        <.header>
          <h1 class="premium-title">Welcome to BiBi . ݁₊</h1>
          <p class="text-lg">
            This site is a meeting place for bisexual men and women who are looking for genuine connections,
            meaningful relationships, and long-term love. Whether you’re seeking a deep emotional bond or a
            committed partnership, this platform offers a welcoming space to connect, chat, and build something real – and it’s free!
          </p>
        </.header>
      </.card>
      <br />
      <.header>
        🌎 Global Users
        <div class="grid grid-cols-1 lg:grid-cols-3 gap-3">
          <%= for profile <- @global_profiles do %>
            <.card
              no_background={false}
              class="m-1 border-b-2 border-transparent hover:border-blue-300 transition-all duration-200"
            >
              <div class="relative">
                <.live_component
                  id={profile.id}
                  module={Carousel}
                  uploaded_files={profile.profile_pictures}
                  length={1}
                />
                <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/50 to-transparent p-4 rounded-b-lg">
                  <.link
                    navigate={~p"/profiles/#{profile.id}"}
                    class="text-white font-semibold text-lg hover:text-gray-100 transition-colors"
                  >
                    <.name_with_online_activity profile={profile} />
                  </.link>
                </div>
              </div>

              <div class="p-4 space-y-2">
                <div class="grid grid-cols-2 gap-3 text-sm">
                  <div class="flex items-center gap-2 text-gray-600">
                    <.icon name="hero-rectangle-stack" class="w-4 h-4" />
                    <span>{Profiles.display_height(profile.height_cm)}</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-600">
                    <.icon name="hero-scale-solid" class="w-4 h-4" />
                    <span>{Profiles.display_weight(profile.weight_lb)}</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-600">
                    <.icon name="hero-cake-solid" class="w-4 h-4" />
                    <span>{profile.age} years</span>
                  </div>
                  <div class="flex items-center gap-2 text-gray-600">
                    <.icon name="hero-map-pin-solid" class="w-4 h-4" />
                    <span>{Profiles.display_distance(profile.distance)} miles away</span>
                  </div>
                </div>
              </div>
            </.card>
          <% end %>
        </div>
      </.header>
      <.header>
        New users
      </.header>
      <.header>
        Members that viewed you
      </.header>
      <.header>
        Members that heart you
      </.header>
    </.page_align>
    """
  end

  def mount(_params, _session, socket) do
    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)
    socket = assign(socket, stripe_customer: stripe_customer)

    global_profiles = Profiles.find_global_users(10)

    {:ok, assign(socket, global_profiles: global_profiles)}
  end
end
