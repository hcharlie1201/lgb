defmodule LgbWeb.ProfileLive.Show do
  use LgbWeb, :live_view
  alias Lgb.Chatting
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

  def handle_event("go", %{"id" => other_profile_id}, socket) do
    user = socket.assigns.current_user
    profile = User.current_profile(user)
    other_profile = Profiles.get_profile!(other_profile_id)

    conversation =
      Chatting.get_or_create_conversation(profile, other_profile)

    {:noreply, push_navigate(socket, to: ~p"/conversations/#{conversation.id}")}
  end
end
