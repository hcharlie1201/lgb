defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  alias Lgb.Messaging

  def render(assigns) do
    ~H"""
    <div class="flex justify-center w-screen">
      <div class="flex flex-col border border-colorPrimary rounded-md">
        <ul class="flex flex-col w-80 text-center">
          <.link class="hover:bg-colorPrimary p-4" href={~p"/profiles/current"}>My Profile</.link>
          <.link class="hover:bg-colorPrimary p-4" href={~p"/profiles"}>Search profiles</.link>
          <.link class="hover:bg-colorPrimary p-4" href={~p"/conversations"}>Inbox/Chats</.link>
          <.link class="hover:bg-colorPrimary p-4" href={~p"/chat_rooms"}>Go to chatroom</.link>
        </ul>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
