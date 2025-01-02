defmodule LgbWeb.ProfileLive.Search do
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}))}
  end

  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  def handle_event("search", params, socket) do
    query_string = URI.encode_query(params)
    socket = socket |> push_navigate(to: ~p"/profiles/results" <> "?" <> query_string)
    {:noreply, socket}
  end
end
