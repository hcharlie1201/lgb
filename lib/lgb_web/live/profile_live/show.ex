defmodule LgbWeb.ProfileLive.Show do
  use LgbWeb, :live_view

  alias Lgb.Profiles

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    profile = Profiles.get_profile!(id)

    {:noreply,
     socket
     |> assign(:profile, profile)
     |> assign(:uploaded_files, Profiles.list_profile_pictures(profile))}
  end
end
