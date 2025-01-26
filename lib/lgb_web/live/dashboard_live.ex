defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="flex justify-center w-screen">
      <div class="flex flex-col border border-colorPrimary rounded-md">
        <ul class="flex flex-col w-80 text-center">
          <.link class="hover:bg-colorPrimary p-4" navigate={~p"/profiles/current"}>My Profile</.link>
          <.link class="hover:bg-colorPrimary p-4" navigate={~p"/profiles"}>Search profiles</.link>
          <.link class="hover:bg-colorPrimary p-4" navigate={~p"/conversations"}>Inbox/Chats</.link>
          <.link class="hover:bg-colorPrimary p-4" navigate={~p"/chat_rooms"}>Go to chatroom</.link>
          <.link class="hover:bg-colorPrimary p-4" navigate={~p"/shopping/subscriptions"}>
            Premium Features
          </.link>
          <%= if @stripe_customer do %>
            <.link class="hover:bg-colorPrimary p-4" href={~p"/account"}>
              My Account
            </.link>
          <% end %>
        </ul>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)
    socket = assign(socket, stripe_customer: stripe_customer)
    {:ok, socket}
  end
end
