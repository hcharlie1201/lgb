defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  alias Lgb.Profiles

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
        <div class="display-grid">
          <%= for profile <- @global_profiles do %>
            <.live_component
              id={"global_users_#{profile.uuid}"}
              module={LgbWeb.Components.ProfilePreview}
              profile={profile}
              current_user={@current_user}
              prefix_id="global_users"
            />
          <% end %>
        </div>
      </.header>
      <.header>
        🍃 New & Nearby users
        <div class="display-grid">
          <%= for profile <- @new_and_nearby do %>
            <.live_component
              id={"new_and_nearby_#{profile.uuid}"}
              module={LgbWeb.Components.ProfilePreview}
              profile={profile}
              current_user={@current_user}
              prefix_id="new_and_nearby"
            />
          <% end %>
        </div>
      </.header>
      <.header>
        Members that viewed you
        <div class="display-grid">
          <%= for profile <- @viewers do %>
            <.live_component
              id={"viewer_#{profile.uuid}"}
              module={LgbWeb.Components.ProfilePreview}
              profile={profile}
              current_user={@current_user}
              prefix_id="viewer"
            />
          <% end %>
        </div>
      </.header>
    </.page_align>
    """
  end

  def mount(_params, _session, socket) do
    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)
    socket = assign(socket, stripe_customer: stripe_customer)
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    global_profiles = Profiles.find_global_users(10, profile)
    new_and_nearby = Profiles.find_new_and_nearby_users(10, profile)
    viewed_your_profile = Lgb.ProfileViews.find_profile_views(profile)

    {:ok,
     assign(socket,
       global_profiles: global_profiles,
       new_and_nearby: new_and_nearby,
       viewers: viewed_your_profile
     )}
  end
end
