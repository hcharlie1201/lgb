defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  alias Lgb.Messaging

  def render(assigns) do
    ~H"""
    <div class="flex">
      <div class="flex-1">
        <ul class="flex flex-col">
          <.link class="hover:bg-sky-200" href={~p"/profiles/current"}>My Profile</.link>
          <.link class="hover:bg-sky-200" href={~p"/profiles"}>Search profiles</.link>
          <.link class="hover:bg-sky-200" href={~p"/chat_rooms"}>Inbox/Chats</.link>
          <.link class="hover:bg-sky-200" href={~p"/chat_rooms"}>Go to chatroom</.link>
        </ul>
      </div>
      <div class="flex-2">
        whatever
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
