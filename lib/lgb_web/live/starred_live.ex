defmodule LgbWeb.StarredLive do
  use LgbWeb, :live_view

  def render(assigns) do
    ~H"""
    <.page_align>
      <div id="starred_stream" class="display-grid" phx-update="stream">
        <div :for={{dom_id, profile} <- @streams.profiles} id={dom_id}>
          <.live_component
            module={LgbWeb.Components.ProfilePreview}
            profile={profile}
            prefix_id="starred"
            current_user={@current_user}
            id={"starred_#{profile.uuid}"}
          />
        </div>
      </div>
    </.page_align>
    """
  end

  def mount(_params, _session, socket) do
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    starred_profiles = Lgb.Profiles.list_starred_profile(profile)

    {:ok,
     socket
     |> stream_configure(:profiles, dom_id: &"profiles-#{&1.uuid}")
     |> stream(:profiles, starred_profiles)}
  end

  def handle_info({:remove_profile, profile}, socket) do
    {:noreply, stream_delete(socket, :profiles, profile)}
  end
end
