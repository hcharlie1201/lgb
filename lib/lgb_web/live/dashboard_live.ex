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
            <.profile_preview profile={profile} />
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
