defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  alias Lgb.Messaging

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.link href={~p"/chat_rooms"}>Go to chatroom</.link>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
