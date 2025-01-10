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

  @impl true
  def handle_event("message", %{"id" => other_profile_id}, socket) do
    user = socket.assigns.current_user
    profile = Lgb.Accounts.User.current_profile(user)
    other_profile = Profiles.get_profile!(other_profile_id)

    case Chatting.get_or_create_conversation(profile, other_profile) do
      {:ok, conversation} ->
        {:noreply, push_navigate(socket, to: ~p"/conversations/#{conversation.id}")}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
