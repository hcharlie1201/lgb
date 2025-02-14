defmodule LgbWeb.CookLive do
  use LgbWeb, :live_view

  #Use render for static pages, use only mount for rendering an HTML page
  # def render(assigns) do
  #   ~H"""
  #   <div>hi</div>
  #   {@s}
  #   """
  # end

  def mount(_params, _session, socket) do
    socket = assign(socket, s: 1, t: 2)
    {:ok, socket}
  end
end
